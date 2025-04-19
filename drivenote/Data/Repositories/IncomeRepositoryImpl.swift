import Foundation
import CoreData
import Combine

class CoreDataIncomeRepository: IncomeRepository {
    
    private let coreDataManager = CoreDataManager.shared
    
    func getAllIncome() -> AnyPublisher<[Income], Error> {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        return coreDataManager.fetchPublisher(CDIncome.self, sortDescriptors: [sortDescriptor])
            .map { cdIncomes in
                return cdIncomes.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func getIncomeById(id: UUID) -> AnyPublisher<Income?, Error> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return coreDataManager.fetchPublisher(CDIncome.self, predicate: predicate)
            .map { cdIncomes in
                return cdIncomes.first?.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
    func getIncomeByDateRange(start: Date, end: Date) -> AnyPublisher<[Income], Error> {
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        return coreDataManager.fetchPublisher(CDIncome.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdIncomes in
                return cdIncomes.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func getIncomeBySource(source: Income.IncomeSource) -> AnyPublisher<[Income], Error> {
        let predicate = NSPredicate(format: "source == %@", source.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        return coreDataManager.fetchPublisher(CDIncome.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdIncomes in
                return cdIncomes.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func saveIncome(income: Income) -> AnyPublisher<Income, Error> {
        return coreDataManager.performBackgroundTask { context in
            // Check if income already exists (update) or is new (create)
            let fetchRequest = NSFetchRequest<CDIncome>(entityName: "CDIncome")
            fetchRequest.predicate = NSPredicate(format: "id == %@", income.id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let existingIncome = results.first {
                existingIncome.update(with: income, context: context)
            } else {
                _ = CDIncome.createFrom(income: income, context: context)
            }
            
            // Return domain model
            return income
        }
    }
    
    func deleteIncome(id: UUID) -> AnyPublisher<Void, Error> {
        return coreDataManager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<CDIncome>(entityName: "CDIncome")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let incomeToDelete = results.first {
                context.delete(incomeToDelete)
            }
            
            return ()
        }
    }
    
    func syncIncome() -> AnyPublisher<Void, Error> {
        // This would be implemented when Firebase is integrated
        // For now, just return a completed publisher
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getUnsyncedIncome() -> AnyPublisher<[Income], Error> {
        let predicate = NSPredicate(format: "isUploaded == %@", NSNumber(value: false))
        let sortDescriptor = NSSortDescriptor(key: "lastModified", ascending: false)
        
        return coreDataManager.fetchPublisher(CDIncome.self, predicate: predicate, sortDescriptors: [sortDescriptor])
            .map { cdIncomes in
                return cdIncomes.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func markIncomeAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return coreDataManager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<CDIncome>(entityName: "CDIncome")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try context.fetch(fetchRequest)
            
            if let income = results.first {
                income.isUploaded = true
            }
            
            return ()
        }
    }
    
    func getTotalIncome(start: Date, end: Date) -> AnyPublisher<Double, Error> {
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        
        return coreDataManager.fetchPublisher(CDIncome.self, predicate: predicate)
            .map { cdIncomes in
                return cdIncomes.reduce(0) { $0 + $1.amount + $1.tipAmount }
            }
            .eraseToAnyPublisher()
    }
    
    func getTotalTips(start: Date, end: Date) -> AnyPublisher<Double, Error> {
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        
        return coreDataManager.fetchPublisher(CDIncome.self, predicate: predicate)
            .map { cdIncomes in
                return cdIncomes.reduce(0) { $0 + $1.tipAmount }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Firebase implementation would be added later
// class FirebaseIncomeRepository: IncomeRepository { ... }

// MARK: - Main Repository Implementation that combines local and remote
class IncomeRepositoryImpl: IncomeRepository {
    private let localRepository: CoreDataIncomeRepository
    // private let remoteRepository: FirebaseIncomeRepository
    
    init(localRepository: CoreDataIncomeRepository) {
        self.localRepository = localRepository
        // self.remoteRepository = remoteRepository
    }
    
    // Delegate to local repository for MVP phase
    func getAllIncome() -> AnyPublisher<[Income], Error> {
        return localRepository.getAllIncome()
    }
    
    func getIncomeById(id: UUID) -> AnyPublisher<Income?, Error> {
        return localRepository.getIncomeById(id: id)
    }
    
    func getIncomeByDateRange(start: Date, end: Date) -> AnyPublisher<[Income], Error> {
        return localRepository.getIncomeByDateRange(start: start, end: end)
    }
    
    func getIncomeBySource(source: Income.IncomeSource) -> AnyPublisher<[Income], Error> {
        return localRepository.getIncomeBySource(source: source)
    }
    
    func saveIncome(income: Income) -> AnyPublisher<Income, Error> {
        return localRepository.saveIncome(income: income)
    }
    
    func deleteIncome(id: UUID) -> AnyPublisher<Void, Error> {
        return localRepository.deleteIncome(id: id)
    }
    
    func syncIncome() -> AnyPublisher<Void, Error> {
        return localRepository.syncIncome()
    }
    
    func getUnsyncedIncome() -> AnyPublisher<[Income], Error> {
        return localRepository.getUnsyncedIncome()
    }
    
    func markIncomeAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return localRepository.markIncomeAsSynced(id: id)
    }
    
    func getTotalIncome(start: Date, end: Date) -> AnyPublisher<Double, Error> {
        return localRepository.getTotalIncome(start: start, end: end)
    }
    
    func getTotalTips(start: Date, end: Date) -> AnyPublisher<Double, Error> {
        return localRepository.getTotalTips(start: start, end: end)
    }
}
