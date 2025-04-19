import Foundation
import CoreData
import Combine

class CoreDataMileageRepository: MileageRepository {
    
    private let coreDataManager = CoreDataManager.shared
    
    func getAllMileage() -> AnyPublisher<[Mileage], Error> {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        return coreDataManager.fetchPublisher(CDMileage.self, sortDescriptors: [sortDescriptor])
            .map { cdMileages in
                return cdMileages.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func getMileageById(id: UUID) -> AnyPublisher<Mileage?, Error> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return coreDataManager.fetchPublisher(CDMileage.self, predicate: predicate)
            .map { cdMileages in
                return cdMileages.first?.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
    func getMileageByDateRange(start: Date, end: Date) -> AnyPublisher<[Mileage], Error> {
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        return coreDataManager.fetchPublisher(CDMileage.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdMileages in
                return cdMileages.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func saveMileage(mileage: Mileage) -> AnyPublisher<Mileage, Error> {
        return coreDataManager.performBackgroundTask { context in
            // Check if mileage already exists (update) or is new (create)
            let fetchRequest = NSFetchRequest<CDMileage>(entityName: "CDMileage")
            fetchRequest.predicate = NSPredicate(format: "id == %@", mileage.id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let existingMileage = results.first {
                existingMileage.update(with: mileage, context: context)
            } else {
                _ = CDMileage.createFrom(mileage: mileage, context: context)
            }
            
            // Return domain model
            return mileage
        }
    }
    
    func deleteMileage(id: UUID) -> AnyPublisher<Void, Error> {
        return coreDataManager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<CDMileage>(entityName: "CDMileage")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let mileageToDelete = results.first {
                context.delete(mileageToDelete)
            }
            
            return ()
        }
    }
    
    func syncMileage() -> AnyPublisher<Void, Error> {
        // This would be implemented when Firebase is integrated
        // For now, just return a completed publisher
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getUnsyncedMileage() -> AnyPublisher<[Mileage], Error> {
        let predicate = NSPredicate(format: "isUploaded == %@", NSNumber(value: false))
        let sortDescriptor = NSSortDescriptor(key: "lastModified", ascending: false)
        
        return coreDataManager.fetchPublisher(CDMileage.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdMileages in
                return cdMileages.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func markMileageAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return coreDataManager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<CDMileage>(entityName: "CDMileage")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let mileage = results.first {
                mileage.isUploaded = true
            }
            
            return ()
        }
    }
    
    func getTotalMileage(start: Date, end: Date) -> AnyPublisher<Double, Error> {
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        
        return coreDataManager.fetchPublisher(CDMileage.self, predicate: predicate)
            .map { cdMileages in
                return cdMileages.reduce(0) { $0 + $1.distance }
            }
            .eraseToAnyPublisher()
    }
    
    func getMileageByFuelExpenseId(expenseId: UUID) -> AnyPublisher<[Mileage], Error> {
        let predicate = NSPredicate(format: "relatedFuelExpenseId == %@", expenseId as CVarArg)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        return coreDataManager.fetchPublisher(CDMileage.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdMileages in
                return cdMileages.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Firebase implementation would be added later
// class FirebaseMileageRepository: MileageRepository { ... }

// MARK: - Main Repository Implementation that combines local and remote
class MileageRepositoryImpl: MileageRepository {
    private let localRepository: CoreDataMileageRepository
    // private let remoteRepository: FirebaseMileageRepository
    
    init(localRepository: CoreDataMileageRepository) {
        self.localRepository = localRepository
        // self.remoteRepository = remoteRepository
    }
    
    // Delegate to local repository for MVP phase
    func getAllMileage() -> AnyPublisher<[Mileage], Error> {
        return localRepository.getAllMileage()
    }
    
    func getMileageById(id: UUID) -> AnyPublisher<Mileage?, Error> {
        return localRepository.getMileageById(id: id)
    }
    
    func getMileageByDateRange(start: Date, end: Date) -> AnyPublisher<[Mileage], Error> {
        return localRepository.getMileageByDateRange(start: start, end: end)
    }
    
    func saveMileage(mileage: Mileage) -> AnyPublisher<Mileage, Error> {
        return localRepository.saveMileage(mileage: mileage)
    }
    
    func deleteMileage(id: UUID) -> AnyPublisher<Void, Error> {
        return localRepository.deleteMileage(id: id)
    }
    
    func syncMileage() -> AnyPublisher<Void, Error> {
        return localRepository.syncMileage()
    }
    
    func getUnsyncedMileage() -> AnyPublisher<[Mileage], Error> {
        return localRepository.getUnsyncedMileage()
    }
    
    func markMileageAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return localRepository.markMileageAsSynced(id: id)
    }
    
    func getTotalMileage(start: Date, end: Date) -> AnyPublisher<Double, Error> {
        return localRepository.getTotalMileage(start: start, end: end)
    }
    
    func getMileageByFuelExpenseId(expenseId: UUID) -> AnyPublisher<[Mileage], Error> {
        return localRepository.getMileageByFuelExpenseId(expenseId: expenseId)
    }
}
