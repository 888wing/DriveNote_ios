import Foundation
import CoreData
import Combine

class CoreDataWorkHoursRepository: WorkHoursRepository {
    
    private let coreDataManager = CoreDataManager.shared
    
    func getAllWorkHours() -> AnyPublisher<[WorkHours], Error> {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        return coreDataManager.fetchPublisher(CDWorkHours.self, sortDescriptors: [sortDescriptor])
            .map { cdWorkHours in
                return cdWorkHours.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func getWorkHoursById(id: UUID) -> AnyPublisher<WorkHours?, Error> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return coreDataManager.fetchPublisher(CDWorkHours.self, predicate: predicate)
            .map { cdWorkHours in
                return cdWorkHours.first?.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
    func getWorkHoursByDateRange(start: Date, end: Date) -> AnyPublisher<[WorkHours], Error> {
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        return coreDataManager.fetchPublisher(CDWorkHours.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdWorkHours in
                return cdWorkHours.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func saveWorkHours(workHours: WorkHours) -> AnyPublisher<WorkHours, Error> {
        return coreDataManager.performBackgroundTask { context in
            // Check if workHours already exists (update) or is new (create)
            let fetchRequest = NSFetchRequest<CDWorkHours>(entityName: "CDWorkHours")
            fetchRequest.predicate = NSPredicate(format: "id == %@", workHours.id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let existingWorkHours = results.first {
                existingWorkHours.update(with: workHours, context: context)
            } else {
                _ = CDWorkHours.createFrom(workHours: workHours, context: context)
            }
            
            // Return domain model
            return workHours
        }
    }
    
    func deleteWorkHours(id: UUID) -> AnyPublisher<Void, Error> {
        return coreDataManager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<CDWorkHours>(entityName: "CDWorkHours")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let workHoursToDelete = results.first {
                context.delete(workHoursToDelete)
            }
            
            return ()
        }
    }
    
    func syncWorkHours() -> AnyPublisher<Void, Error> {
        // This would be implemented when Firebase is integrated
        // For now, just return a completed publisher
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getUnsyncedWorkHours() -> AnyPublisher<[WorkHours], Error> {
        let predicate = NSPredicate(format: "isUploaded == %@", NSNumber(value: false))
        let sortDescriptor = NSSortDescriptor(key: "lastModified", ascending: false)
        
        return coreDataManager.fetchPublisher(CDWorkHours.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdWorkHours in
                return cdWorkHours.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func markWorkHoursAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return coreDataManager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<CDWorkHours>(entityName: "CDWorkHours")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let workHours = results.first {
                workHours.isUploaded = true
            }
            
            return ()
        }
    }
    
    func getTotalWorkHours(start: Date, end: Date) -> AnyPublisher<Double, Error> {
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        
        return coreDataManager.fetchPublisher(CDWorkHours.self, predicate: predicate)
            .map { cdWorkHours in
                return cdWorkHours.reduce(0) { $0 + $1.totalHours }
            }
            .eraseToAnyPublisher()
    }
    
    func getTodayWorkHours() -> AnyPublisher<WorkHours?, Error> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        return coreDataManager.fetchPublisher(CDWorkHours.self, predicate: predicate)
            .map { cdWorkHours in
                return cdWorkHours.first?.toDomain()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Firebase implementation would be added later
// class FirebaseWorkHoursRepository: WorkHoursRepository { ... }

// MARK: - Main Repository Implementation that combines local and remote
class WorkHoursRepositoryImpl: WorkHoursRepository {
    private let localRepository: CoreDataWorkHoursRepository
    // private let remoteRepository: FirebaseWorkHoursRepository
    
    init(localRepository: CoreDataWorkHoursRepository) {
        self.localRepository = localRepository
        // self.remoteRepository = remoteRepository
    }
    
    // Delegate to local repository for MVP phase
    func getAllWorkHours() -> AnyPublisher<[WorkHours], Error> {
        return localRepository.getAllWorkHours()
    }
    
    func getWorkHoursById(id: UUID) -> AnyPublisher<WorkHours?, Error> {
        return localRepository.getWorkHoursById(id: id)
    }
    
    func getWorkHoursByDateRange(start: Date, end: Date) -> AnyPublisher<[WorkHours], Error> {
        return localRepository.getWorkHoursByDateRange(start: start, end: end)
    }
    
    func saveWorkHours(workHours: WorkHours) -> AnyPublisher<WorkHours, Error> {
        return localRepository.saveWorkHours(workHours: workHours)
    }
    
    func deleteWorkHours(id: UUID) -> AnyPublisher<Void, Error> {
        return localRepository.deleteWorkHours(id: id)
    }
    
    func syncWorkHours() -> AnyPublisher<Void, Error> {
        return localRepository.syncWorkHours()
    }
    
    func getUnsyncedWorkHours() -> AnyPublisher<[WorkHours], Error> {
        return localRepository.getUnsyncedWorkHours()
    }
    
    func markWorkHoursAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return localRepository.markWorkHoursAsSynced(id: id)
    }
    
    func getTotalWorkHours(start: Date, end: Date) -> AnyPublisher<Double, Error> {
        return localRepository.getTotalWorkHours(start: start, end: end)
    }
    
    func getTodayWorkHours() -> AnyPublisher<WorkHours?, Error> {
        return localRepository.getTodayWorkHours()
    }
}
