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
        // 打印當前工作目錄和可用的 xcdatamodeld 文件
        print("CoreDataManager: 正在初始化 Core Data 堆棧")
        print("CoreDataManager: 模型名稱為 'drivenote'")
        
        let container = NSPersistentContainer(name: "drivenote")
        
        // 嘗試載入持久化存儲，但提供更安全的錯誤處理
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("CoreDataManager: Core Data 載入錯誤 - \(error.localizedDescription)")
                print("CoreDataManager: 詳細錯誤信息 - \(error.userInfo)")
                
                // 嘗試處理某些常見錯誤
                if error.domain == NSCocoaErrorDomain && 
                   (error.code == NSMigrationError || 
                    error.code == NSMigrationMissingSourceModelError || 
                    error.code == NSMigrationMissingMappingModelError) {
                    print("CoreDataManager: 遇到遷移錯誤，可能需要刪除舊的存儲文件")
                    
                    // 輸出有用的調試信息而不是直接崩潰
                    print("CoreDataManager: 這可能是 Core Data 模型不匹配導致的")
                    print("CoreDataManager: 請確保 xcdatamodeld 文件名正確")
                    print("CoreDataManager: 正在繼續但可能會有功能限制")
                } else {
                    print("CoreDataManager: 未知錯誤，應用可能無法正常工作")
                }
                
                // 創建一個內存存儲作為臨時解決方案，而不是崩潰
                let description = NSPersistentStoreDescription()
                description.type = NSInMemoryStoreType
                container.persistentStoreDescriptions = [description]
                container.loadPersistentStores { (desc, err) in
                    if let err = err {
                        print("CoreDataManager: 無法創建內存存儲: \(err)")
                    } else {
                        print("CoreDataManager: 已創建內存存儲作為備份")
                    }
                }
            } else {
                print("CoreDataManager: Core Data 載入成功")
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
