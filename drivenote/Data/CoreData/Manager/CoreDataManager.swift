import Foundation
import CoreData
import Combine

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        // Private initializer to ensure singleton pattern
    }
    
    // MARK: - Core Data Stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DriveNote")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
        }
        
        // Merge policies
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    // Main context for UI
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Background context for async operations
    func backgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Core Data Operations
    
    // Save context if there are changes
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Failed to save Core Data context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Save context with error handling for publishers
    func saveContextPublisher(_ context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            if context.hasChanges {
                do {
                    try context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            } else {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    // Perform block on background context
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) -> AnyPublisher<T, Error> {
        return Future<T, Error> { promise in
            let context = self.backgroundContext()
            
            context.perform {
                do {
                    let result = try block(context)
                    
                    if context.hasChanges {
                        do {
                            try context.save()
                        } catch {
                            promise(.failure(error))
                            return
                        }
                    }
                    
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Fetch entities with predicate
    func fetch<T: NSManagedObject>(_ entityType: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext? = nil) -> [T] {
        let ctx = context ?? viewContext
        
        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try ctx.fetch(request)
        } catch {
            print("Failed to fetch \(entityType): \(error)")
            return []
        }
    }
    
    // Fetch entities as publisher
    func fetchPublisher<T: NSManagedObject>(_ entityType: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext? = nil) -> AnyPublisher<[T], Error> {
        return Future<[T], Error> { promise in
            let ctx = context ?? self.viewContext
            
            ctx.perform {
                let request = NSFetchRequest<T>(entityName: String(describing: entityType))
                request.predicate = predicate
                request.sortDescriptors = sortDescriptors
                
                do {
                    let results = try ctx.fetch(request)
                    promise(.success(results))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Delete entity
    func delete(_ object: NSManagedObject, context: NSManagedObjectContext? = nil) {
        let ctx = context ?? viewContext
        ctx.delete(object)
        saveContext(ctx)
    }
    
    // Delete entity with publisher
    func deletePublisher(_ object: NSManagedObject, context: NSManagedObjectContext? = nil) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let ctx = context ?? self.viewContext
            
            ctx.perform {
                ctx.delete(object)
                
                do {
                    try ctx.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
