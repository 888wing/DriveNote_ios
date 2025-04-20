import Foundation
import CoreData
import Combine

class CoreDataManager {
    static let shared = CoreDataManager()
    
    // 用於取消訂閱
    var cancellables = Set<AnyCancellable>()
    
    // 狀態追蹤
    private(set) var isInitialized = false
    private(set) var initializationError: Error? = nil
    private(set) var isUsingInMemoryStore = false
    
    private init() {
        // 私有初始化方法確保單例模式
    }
    
    // MARK: - Core Data Stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        print("CoreDataManager: 正在初始化 Core Data 堆棧")
        print("CoreDataManager: 模型名稱為 'drivenote'")
        
        let container = NSPersistentContainer(name: "drivenote")
        return container
    }()
    
    // 主視圖上下文
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // 後台上下文
    func backgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - 初始化方法
    
    // 安全初始化 Core Data 堆棧
    func initializeStack() -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "CoreDataManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "實例已被釋放"])))
                return
            }
            
            if self.isInitialized {
                promise(.success(true))
                return
            }
            
            self.loadPersistentStore { error in
                if let error = error {
                    self.initializationError = error
                    promise(.failure(error))
                } else {
                    self.isInitialized = true
                    self.isUsingInMemoryStore = false
                    promise(.success(true))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // 初始化內存存儲
    func initializeInMemoryStore() -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "CoreDataManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "實例已被釋放"])))
                return
            }
            
            // 創建新的內存容器
            let container = NSPersistentContainer(name: "drivenote")
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            
            container.loadPersistentStores { [weak self] (_, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.initializationError = error
                    promise(.failure(error))
                } else {
                    // 替換現有的容器
                    self.persistentContainer = container
                    self.isInitialized = true
                    self.isUsingInMemoryStore = true
                    promise(.success(true))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // 載入持久化存儲
    private func loadPersistentStore(completion: @escaping (Error?) -> Void) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("CoreDataManager: Core Data 載入錯誤 - \(error.localizedDescription)")
                print("CoreDataManager: 詳細錯誤信息 - \(error.userInfo)")
                completion(error)
                return
            }
            
            print("CoreDataManager: Core Data 載入成功")
            
            // 設置合併策略
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            completion(nil)
        }
    }
    
    // MARK: - 數據庫維護方法
    
    // 移除舊的數據庫文件
    func removeExistingStoreFiles() -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            let fileManager = FileManager.default
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let storeUrl = documentsUrl.appendingPathComponent("drivenote.sqlite")
            
            let filesToDelete = [
                storeUrl,
                storeUrl.appendingPathExtension("shm"),
                storeUrl.appendingPathExtension("wal")
            ]
            
            do {
                for url in filesToDelete where fileManager.fileExists(atPath: url.path) {
                    try fileManager.removeItem(at: url)
                    print("CoreDataManager: 已刪除 \(url.path)")
                }
                promise(.success(true))
            } catch {
                print("CoreDataManager: 刪除文件失敗 - \(error.localizedDescription)")
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // 分析數據庫模型問題
    func analyzeDatabaseIssues() -> AnyPublisher<[String: Any], Error> {
        return Future<[String: Any], Error> { promise in
            var diagInfo = [String: Any]()
            
            // 檢查模型文件是否存在
            let modelURL = Bundle.main.url(forResource: "drivenote", withExtension: "momd")
            diagInfo["modelExists"] = modelURL != nil
            
            // 檢查數據庫文件是否存在
            let fileManager = FileManager.default
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let storeUrl = documentsUrl.appendingPathComponent("drivenote.sqlite")
            diagInfo["storeExists"] = fileManager.fileExists(atPath: storeUrl.path)
            
            // 檢查可用空間
            do {
                let attribs = try fileManager.attributesOfFileSystem(forPath: documentsUrl.path)
                diagInfo["freeSpace"] = attribs[.systemFreeSize] as? Int64 ?? 0
            } catch {
                diagInfo["freeSpaceError"] = error.localizedDescription
            }
            
            // 檢查權限
            diagInfo["canWrite"] = fileManager.isWritableFile(atPath: documentsUrl.path)
            
            // 返回診斷信息
            promise(.success(diagInfo))
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Core Data Operations
    
    // 保存上下文
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
    
    // 帶錯誤處理的保存上下文發布者
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
    
    // 在後台上下文執行代碼塊
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) -> AnyPublisher<T, Error> {
        return Future<T, Error> { promise in
            guard self.isInitialized else {
                promise(.failure(NSError(domain: "CoreDataManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Core Data 尚未初始化"])))
                return
            }
            
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
    
    // 使用謂詞獲取實體
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
    
    // 獲取實體的發布者
    func fetchPublisher<T: NSManagedObject>(_ entityType: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext? = nil) -> AnyPublisher<[T], Error> {
        return Future<[T], Error> { promise in
            guard self.isInitialized else {
                promise(.failure(NSError(domain: "CoreDataManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Core Data 尚未初始化"])))
                return
            }
            
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
    
    // 刪除實體
    func delete(_ object: NSManagedObject, context: NSManagedObjectContext? = nil) {
        let ctx = context ?? viewContext
        ctx.delete(object)
        saveContext(ctx)
    }
    
    // 刪除實體的發布者
    func deletePublisher(_ object: NSManagedObject, context: NSManagedObjectContext? = nil) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            guard self.isInitialized else {
                promise(.failure(NSError(domain: "CoreDataManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Core Data 尚未初始化"])))
                return
            }
            
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

// MARK: - 錯誤類型
extension CoreDataManager {
    enum CoreDataError: Error, LocalizedError {
        case modelNotFound
        case storeCreationFailed(String)
        case notInitialized
        case migrationFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .modelNotFound:
                return "找不到數據模型文件"
            case .storeCreationFailed(let reason):
                return "無法創建數據存儲: \(reason)"
            case .notInitialized:
                return "Core Data 尚未初始化"
            case .migrationFailed(let reason):
                return "數據遷移失敗: \(reason)"
            }
        }
    }
}
