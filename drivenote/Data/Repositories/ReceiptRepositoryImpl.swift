import Foundation
import CoreData
import Combine
import UIKit

class CoreDataReceiptRepository: ReceiptRepository {
    
    private let coreDataManager = CoreDataManager.shared
    private let fileManager = FileManager.default
    
    // Directory for storing receipt images
    private var receiptsDirectory: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let receiptsDirectory = documentsDirectory.appendingPathComponent("Receipts", isDirectory: true)
        
        if !fileManager.fileExists(atPath: receiptsDirectory.path) {
            try? fileManager.createDirectory(at: receiptsDirectory, withIntermediateDirectories: true)
        }
        
        return receiptsDirectory
    }
    
    func getAllReceipts() -> AnyPublisher<[Receipt], Error> {
        let sortDescriptor = NSSortDescriptor(key: "uploadTimestamp", ascending: false)
        
        return coreDataManager.fetchPublisher(CDReceipt.self, sortDescriptors: [sortDescriptor])
            .map { cdReceipts in
                return cdReceipts.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func getReceiptById(id: UUID) -> AnyPublisher<Receipt?, Error> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return coreDataManager.fetchPublisher(CDReceipt.self, predicate: predicate)
            .map { cdReceipts in
                return cdReceipts.first?.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
    func getReceiptsByExpenseId(expenseId: UUID) -> AnyPublisher<[Receipt], Error> {
        // Fetch expense first to access its receipts relationship
        let expensePredicate = NSPredicate(format: "id == %@", expenseId as CVarArg)
        
        return coreDataManager.fetchPublisher(CDExpense.self, predicate: expensePredicate)
            .flatMap { cdExpenses -> AnyPublisher<[Receipt], Error> in
                guard let cdExpense = cdExpenses.first,
                      let cdReceipts = cdExpense.receipts as? Set<CDReceipt> else {
                    return Just([Receipt]()).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                
                let receipts = cdReceipts.map { $0.toDomain() }
                return Just(receipts).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func saveReceipt(receipt: Receipt, imageData: Data) -> AnyPublisher<Receipt, Error> {
        return Deferred {
            Future<Receipt, Error> { promise in
                // Save image to file system
                let fileURL = self.receiptsDirectory.appendingPathComponent(receipt.id.uuidString + ".jpg")
                
                do {
                    try imageData.write(to: fileURL)
                    
                    // Update receipt with file path
                    var updatedReceipt = receipt
                    updatedReceipt.filePath = fileURL.path
                    
                    // Save receipt metadata to Core Data
                    self.coreDataManager.performBackgroundTask { context in
                        // Check if receipt already exists
                        let fetchRequest = NSFetchRequest<CDReceipt>(entityName: "CDReceipt")
                        fetchRequest.predicate = NSPredicate(format: "id == %@", updatedReceipt.id as CVarArg)
                        
                        let results = try context.fetch(fetchRequest)
                        
                        if let existingReceipt = results.first {
                            existingReceipt.update(with: updatedReceipt, context: context)
                        } else {
                            _ = CDReceipt.createFrom(receipt: updatedReceipt, context: context)
                        }
                        
                        return updatedReceipt
                    }
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                promise(.failure(error))
                            }
                        },
                        receiveValue: { updatedReceipt in
                            promise(.success(updatedReceipt))
                        }
                    )
                    .store(in: &self.cancellables)
                    
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getReceiptImage(receipt: Receipt) -> AnyPublisher<UIImage?, Error> {
        return Deferred {
            Future<UIImage?, Error> { promise in
                let fileURL = URL(fileURLWithPath: receipt.filePath)
                
                guard self.fileManager.fileExists(atPath: fileURL.path) else {
                    promise(.success(nil))
                    return
                }
                
                if let imageData = try? Data(contentsOf: fileURL),
                   let image = UIImage(data: imageData) {
                    promise(.success(image))
                } else {
                    promise(.success(nil))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteReceipt(id: UUID) -> AnyPublisher<Void, Error> {
        return getReceiptById(id: id)
            .flatMap { receipt -> AnyPublisher<Void, Error> in
                guard let receipt = receipt else {
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                
                // Delete file from file system
                let fileURL = URL(fileURLWithPath: receipt.filePath)
                if self.fileManager.fileExists(atPath: fileURL.path) {
                    try? self.fileManager.removeItem(at: fileURL)
                }
                
                // Delete from Core Data
                return self.coreDataManager.performBackgroundTask { context in
                    let fetchRequest = NSFetchRequest<CDReceipt>(entityName: "CDReceipt")
                    fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                    
                    let results = try context.fetch(fetchRequest)
                    
                    if let receiptToDelete = results.first {
                        context.delete(receiptToDelete)
                    }
                    
                    return ()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func processReceiptWithOCR(receipt: Receipt) -> AnyPublisher<Receipt, Error> {
        // In MVP phase 1, we will not implement OCR yet
        // Just update the receipt status to completed with empty result
        return updateReceiptOCRStatus(id: receipt.id, status: .completed, resultJson: nil)
    }
    
    func updateReceiptOCRStatus(id: UUID, status: Receipt.OCRStatus, resultJson: String?) -> AnyPublisher<Receipt, Error> {
        return coreDataManager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<CDReceipt>(entityName: "CDReceipt")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            guard let cdReceipt = results.first else {
                throw NSError(domain: "Receipt not found", code: 404)
            }
            
            cdReceipt.ocrStatus = status.rawValue
            if let resultJson = resultJson {
                cdReceipt.ocrResultJson = resultJson
            }
            
            return cdReceipt.toDomain()
        }
    }
    
    func syncReceipts() -> AnyPublisher<Void, Error> {
        // This would be implemented when Firebase is integrated
        // For now, just return a completed publisher
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getUnsyncedReceipts() -> AnyPublisher<[Receipt], Error> {
        let predicate = NSPredicate(format: "isUploaded == %@", NSNumber(value: false))
        let sortDescriptor = NSSortDescriptor(key: "uploadTimestamp", ascending: false)
        
        return coreDataManager.fetchPublisher(CDReceipt.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdReceipts in
                return cdReceipts.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func markReceiptAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return coreDataManager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<CDReceipt>(entityName: "CDReceipt")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let receipt = results.first {
                receipt.isUploaded = true
            }
            
            return ()
        }
    }
    
    func getPendingOCRReceipts() -> AnyPublisher<[Receipt], Error> {
        let predicate = NSPredicate(format: "ocrStatus == %@", Receipt.OCRStatus.pending.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "uploadTimestamp", ascending: true)
        
        return coreDataManager.fetchPublisher(CDReceipt.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdReceipts in
                return cdReceipts.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    // Set of cancellables to store subscriptions
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Firebase implementation would be added later
// class FirebaseReceiptRepository: ReceiptRepository { ... }

// MARK: - Main Repository Implementation that combines local and remote
class ReceiptRepositoryImpl: ReceiptRepository {
    private let localRepository: CoreDataReceiptRepository
    // private let remoteRepository: FirebaseReceiptRepository
    
    init(localRepository: CoreDataReceiptRepository) {
        self.localRepository = localRepository
        // self.remoteRepository = remoteRepository
    }
    
    // Delegate to local repository for MVP phase
    func getAllReceipts() -> AnyPublisher<[Receipt], Error> {
        return localRepository.getAllReceipts()
    }
    
    func getReceiptById(id: UUID) -> AnyPublisher<Receipt?, Error> {
        return localRepository.getReceiptById(id: id)
    }
    
    func getReceiptsByExpenseId(expenseId: UUID) -> AnyPublisher<[Receipt], Error> {
        return localRepository.getReceiptsByExpenseId(expenseId: expenseId)
    }
    
    func saveReceipt(receipt: Receipt, imageData: Data) -> AnyPublisher<Receipt, Error> {
        return localRepository.saveReceipt(receipt: receipt, imageData: imageData)
    }
    
    func getReceiptImage(receipt: Receipt) -> AnyPublisher<UIImage?, Error> {
        return localRepository.getReceiptImage(receipt: receipt)
    }
    
    func deleteReceipt(id: UUID) -> AnyPublisher<Void, Error> {
        return localRepository.deleteReceipt(id: id)
    }
    
    func processReceiptWithOCR(receipt: Receipt) -> AnyPublisher<Receipt, Error> {
        return localRepository.processReceiptWithOCR(receipt: receipt)
    }
    
    func updateReceiptOCRStatus(id: UUID, status: Receipt.OCRStatus, resultJson: String?) -> AnyPublisher<Receipt, Error> {
        return localRepository.updateReceiptOCRStatus(id: id, status: status, resultJson: resultJson)
    }
    
    func syncReceipts() -> AnyPublisher<Void, Error> {
        return localRepository.syncReceipts()
    }
    
    func getUnsyncedReceipts() -> AnyPublisher<[Receipt], Error> {
        return localRepository.getUnsyncedReceipts()
    }
    
    func markReceiptAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return localRepository.markReceiptAsSynced(id: id)
    }
    
    func getPendingOCRReceipts() -> AnyPublisher<[Receipt], Error> {
        return localRepository.getPendingOCRReceipts()
    }
}
