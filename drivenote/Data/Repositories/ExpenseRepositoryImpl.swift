import Foundation
import CoreData
import Combine

class CoreDataExpenseRepository: ExpenseRepository {
    
    private let coreDataManager = CoreDataManager.shared
    
    func getAllExpenses() -> AnyPublisher<[Expense], Error> {
        let fetchRequest = NSFetchRequest<CDExpense>(entityName: "CDExpense")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return coreDataManager.fetchPublisher(CDExpense.self, sortDescriptors: [sortDescriptor])
            .map { cdExpenses in
                return cdExpenses.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func getExpenseById(id: UUID) -> AnyPublisher<Expense?, Error> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return coreDataManager.fetchPublisher(CDExpense.self, predicate: predicate)
            .map { cdExpenses in
                return cdExpenses.first?.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
    func getExpensesByDateRange(start: Date, end: Date) -> AnyPublisher<[Expense], Error> {
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        return coreDataManager.fetchPublisher(CDExpense.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdExpenses in
                return cdExpenses.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func getExpensesByCategory(category: ExpenseCategory) -> AnyPublisher<[Expense], Error> {
        let predicate = NSPredicate(format: "category == %@", category.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        return coreDataManager.fetchPublisher(CDExpense.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdExpenses in
                return cdExpenses.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func saveExpense(expense: Expense) -> AnyPublisher<Expense, Error> {
        return coreDataManager.performBackgroundTask { context in
            // Check if expense already exists (update) or is new (create)
            let fetchRequest = NSFetchRequest<CDExpense>(entityName: "CDExpense")
            fetchRequest.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            let cdExpense: CDExpense
            
            if let existingExpense = results.first {
                cdExpense = existingExpense
                cdExpense.update(with: expense, context: context)
            } else {
                cdExpense = CDExpense.createFrom(expense: expense, context: context)
            }
            
            // Handle receipt relationships if needed
            if let receiptIds = expense.receiptIds, !receiptIds.isEmpty {
                // Fetch all receipts that match the IDs
                let receiptFetchRequest = NSFetchRequest<CDReceipt>(entityName: "CDReceipt")
                receiptFetchRequest.predicate = NSPredicate(format: "id IN %@", receiptIds)
                
                let cdReceipts = try context.fetch(receiptFetchRequest)
                
                // Associate receipts with expense
                let receiptSet = NSSet(array: cdReceipts)
                cdExpense.receipts = receiptSet
            }
            
            // Return domain model
            return expense
        }
    }
    
    func deleteExpense(id: UUID) -> AnyPublisher<Void, Error> {
        return coreDataManager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<CDExpense>(entityName: "CDExpense")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let expenseToDelete = results.first {
                context.delete(expenseToDelete)
            }
            
            return ()
        }
    }
    
    func syncExpenses() -> AnyPublisher<Void, Error> {
        // This would be implemented when Firebase is integrated
        // For now, just return a completed publisher
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getUnsyncedExpenses() -> AnyPublisher<[Expense], Error> {
        let predicate = NSPredicate(format: "isUploaded == %@", NSNumber(value: false))
        let sortDescriptor = NSSortDescriptor(key: "lastModified", ascending: false)
        
        return coreDataManager.fetchPublisher(CDExpense.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdExpenses in
                return cdExpenses.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func markExpenseAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return coreDataManager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<CDExpense>(entityName: "CDExpense")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let expense = results.first {
                expense.isUploaded = true
            }
            
            return ()
        }
    }
    
    func getExpenseByReceiptId(receiptId: UUID) -> AnyPublisher<Expense?, Error> {
        // First fetch the receipt to get its expense relationship
        let receiptPredicate = NSPredicate(format: "id == %@", receiptId as CVarArg)
        
        return coreDataManager.fetchPublisher(CDReceipt.self, predicate: receiptPredicate)
            .flatMap { cdReceipts -> AnyPublisher<Expense?, Error> in
                guard let cdReceipt = cdReceipts.first, let cdExpense = cdReceipt.expense else {
                    return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                
                return Just(cdExpense.toDomain()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Firebase implementation would be added later
// class FirebaseExpenseRepository: ExpenseRepository { ... }

// MARK: - Main Repository Implementation that combines local and remote
class ExpenseRepositoryImpl: ExpenseRepository {
    private let localRepository: CoreDataExpenseRepository
    // private let remoteRepository: FirebaseExpenseRepository
    
    init(localRepository: CoreDataExpenseRepository) {
        self.localRepository = localRepository
        // self.remoteRepository = remoteRepository
    }
    
    // Delegate to local repository for MVP phase
    func getAllExpenses() -> AnyPublisher<[Expense], Error> {
        return localRepository.getAllExpenses()
    }
    
    func getExpenseById(id: UUID) -> AnyPublisher<Expense?, Error> {
        return localRepository.getExpenseById(id: id)
    }
    
    func getExpensesByDateRange(start: Date, end: Date) -> AnyPublisher<[Expense], Error> {
        return localRepository.getExpensesByDateRange(start: start, end: end)
    }
    
    func getExpensesByCategory(category: ExpenseCategory) -> AnyPublisher<[Expense], Error> {
        return localRepository.getExpensesByCategory(category: category)
    }
    
    func saveExpense(expense: Expense) -> AnyPublisher<Expense, Error> {
        return localRepository.saveExpense(expense: expense)
    }
    
    func deleteExpense(id: UUID) -> AnyPublisher<Void, Error> {
        return localRepository.deleteExpense(id: id)
    }
    
    func syncExpenses() -> AnyPublisher<Void, Error> {
        return localRepository.syncExpenses()
    }
    
    func getUnsyncedExpenses() -> AnyPublisher<[Expense], Error> {
        return localRepository.getUnsyncedExpenses()
    }
    
    func markExpenseAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return localRepository.markExpenseAsSynced(id: id)
    }
    
    func getExpenseByReceiptId(receiptId: UUID) -> AnyPublisher<Expense?, Error> {
        return localRepository.getExpenseByReceiptId(receiptId: receiptId)
    }
}
