import UIKit
import CoreData
import Combine
// import Firebase  // 註解掉 Firebase 導入

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure Firebase - Commented out for MVP phase 1
        // FirebaseApp.configure()
        
        // 不再啟動時立即進行 Core Data 驗證，避免啟動崩潰
        print("AppDelegate: 應用程序啟動，跳過 Core Data 驗證")
        
        return true
    }
    
    private func verifyCoreDateEntities() {
        print("AppDelegate: 嘗試驗證 Core Data 實體...")
        
        // 延遲執行以確保 Core Data 堆棧已完全初始化
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 安全地獲取 context
            let context = CoreDataManager.shared.viewContext
            
            // 檢查實體是否存在
            print("AppDelegate: 開始驗證 Core Data 實體")
            let entityNames = ["CDExpense", "CDMileage", "CDWorkHours", "CDReceipt", "CDIncome"]
            
            var allEntitiesValid = true
            
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                fetchRequest.fetchLimit = 1
                
                do {
                    _ = try context.fetch(fetchRequest)
                    print("✅ Core Data 實體: \(entityName) - 成功")
                } catch {
                    print("❌ Core Data 實體: \(entityName) - 失敗: \(error)")
                    allEntitiesValid = false
                }
            }
            
            if allEntitiesValid {
                print("✅✅ 所有 Core Data 實體驗證成功")
                self.insertSampleDataIfNeeded()
            } else {
                print("⚠️⚠️ 部分 Core Data 實體驗證失敗!")
            }
        }
    }
    
    private func insertSampleDataIfNeeded() {
        // 檢查是否已有任何支出數據
        let context = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDExpense")
        fetchRequest.fetchLimit = 1
        
        do {
            let result = try context.fetch(fetchRequest)
            if result.isEmpty {
                print("📊 插入樣本數據以便測試...")
                _ = createSampleExpense()
            } else {
                print("👍 已存在數據，無需插入樣本")
            }
        } catch {
            print("❌ 檢查支出記錄時出錯: \(error)")
        }
    }
    
    private func createSampleExpense() -> AnyPublisher<Void, Error> {
        return CoreDataManager.shared.performBackgroundTask { context in
            let expense = CDExpense(context: context)
            expense.id = UUID()
            expense.date = Date()
            expense.amount = 88.88
            expense.category = "fuel"
            expense.descriptionText = "樣本數據：加油"
            expense.isTaxDeductible = true
            expense.taxDeductiblePercentage = 100
            expense.creationMethod = "manual"
            expense.isUploaded = false
            expense.lastModified = Date()
            
            do {
                try context.save()
                print("✅ 樣本數據創建成功")
            } catch {
                print("❌ 樣本數據創建失敗: \(error)")
            }
            
            return () // 返回空元組，滿足返回類型
        }
    }
}
