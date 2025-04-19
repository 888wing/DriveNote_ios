import SwiftUI
import CoreData
import Combine

// 緊急修復視圖 - 用於繞過 Core Data 問題
struct AppFixerView: View {
    @State private var message = "正在進行應用程序診斷..."
    @State private var showMainApp = false
    @State private var showEmergencySettings = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("DriveNote 修復模式")
                .font(.title)
                .bold()
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .onAppear {
                    diagnoseApp()
                }
            
            if showEmergencySettings {
                Button(action: {
                    showEmergencySettings = true
                }) {
                    Text("進入應急設置")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showEmergencySettings) {
                    NavigationView {
                        EmergencySettingsView()
                            .navigationTitle("應急設置")
                    }
                }
            }
            
            Button(action: {
                resetCoreDataStore()
            }) {
                Text("重置數據庫並重試")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
    
    func diagnoseApp() {
        // 檢查 Core Data 模型是否存在
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            message = "檢查數據模型文件中..."
            
            // 檢查是否能創建內存數據庫
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            
            let container = NSPersistentContainer(name: "drivenote")
            container.persistentStoreDescriptions = [description]
            
            container.loadPersistentStores { (_, error) in
                if let error = error {
                    message = "數據模型有問題: \(error.localizedDescription)"
                    showEmergencySettings = true
                } else {
                    message = "數據模型正常，但 SQLite 存儲可能損壞。請重置數據庫。"
                }
            }
        }
    }
    
    func resetCoreDataStore() {
        message = "正在重置數據庫..."
        
        // 移除 SQLite 文件
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let storeUrl = documentsUrl.appendingPathComponent("drivenote.sqlite")
        
        // 嘗試刪除相關 Core Data 文件
        let filesToDelete = [
            storeUrl,
            storeUrl.appendingPathExtension("shm"),
            storeUrl.appendingPathExtension("wal")
        ]
        
        var success = true
        for url in filesToDelete {
            if fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.removeItem(at: url)
                } catch {
                    message = "無法刪除數據庫文件: \(error.localizedDescription)"
                    success = false
                    break
                }
            }
        }
        
        if success {
            message = "數據庫已重置，應用將在3秒後重新啟動..."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                exit(0) // 強制關閉應用，用戶需要手動重啟
            }
        }
    }
}

// 緊急設置視圖
struct EmergencySettingsView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        List {
            Section(header: Text("診斷工具")) {
                Button("檢查文件系統") {
                    checkFileSystem()
                }
                
                Button("檢查數據模型") {
                    checkDataModel()
                }
                
                Button("重置應用") {
                    resetAllData()
                }
            }
            
            Section(header: Text("狀態信息")) {
                HStack {
                    Text("iOS 版本")
                    Spacer()
                    Text(UIDevice.current.systemVersion)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("設備型號")
                    Spacer()
                    Text(UIDevice.current.model)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("可用空間")
                    Spacer()
                    Text(getAvailableSpace())
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("診斷結果"), message: Text(alertMessage), dismissButton: .default(Text("確定")))
        }
    }
    
    func checkFileSystem() {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            alertMessage = "找到 \(files.count) 個文件:\n" + files.map { $0.lastPathComponent }.joined(separator: "\n")
        } catch {
            alertMessage = "無法讀取文件系統: \(error.localizedDescription)"
        }
        
        showAlert = true
    }
    
    func checkDataModel() {
        let modelURL = Bundle.main.url(forResource: "drivenote", withExtension: "momd")
        
        if modelURL != nil {
            alertMessage = "找到數據模型文件"
        } else {
            alertMessage = "找不到數據模型文件!\n這是導致問題的主要原因。"
        }
        
        showAlert = true
    }
    
    func resetAllData() {
        // 清除應用的所有數據
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        
        // 刪除所有文件
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
            alertMessage = "已清除所有應用數據。請完全退出應用並重新啟動。"
        } catch {
            alertMessage = "清除數據失敗: \(error.localizedDescription)"
        }
        
        showAlert = true
    }
    
    func getAvailableSpace() -> String {
        do {
            let fileURL = URL(fileURLWithPath: NSHomeDirectory())
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let capacity = values.volumeAvailableCapacityForImportantUsage {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useGB]
                formatter.countStyle = .file
                return formatter.string(fromByteCount: Int64(capacity))
            }
        } catch {
            return "無法獲取"
        }
        return "無法獲取"
    }
}

@main
struct DriveNoteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // 完全繞過 Core Data 初始化，直接進入緊急修復模式
    var body: some Scene {
        WindowGroup {
            // 直接顯示緊急修復視圖
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("緊急啟動模式")
                    .font(.title)
                    .bold()
                
                Text("檢測到應用程序數據庫問題")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("請使用以下選項修復應用")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    // 進入主應用（Tab 導航）
                    showSettingsView()
                }) {
                    HStack {
                        Image(systemName: "tablecells")
                        Text("進入主應用")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top)
                
                Button(action: {
                    // 重置數據庫
                    performDatabaseReset()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("重置數據庫")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top, 5)
                
                Button(action: {
                    // 嘗試修復
                    performAdvancedRepair()
                }) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver")
                        Text("高級修復工具")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top, 5)
            }
            .padding(30)
        }
    }
    
    // 顯示主應用（包含 TabView）
    private func showSettingsView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let contentView = ContentView()
            window.rootViewController = UIHostingController(rootView: contentView)
            
            // 打印一條日誌信息
            print("已切換到主應用 ContentView，應該顯示 TabView")
        }
    }
    
    // 執行數據庫重置
    private func performDatabaseReset() {
        // 移除 SQLite 文件
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let storeUrl = documentsUrl.appendingPathComponent("drivenote.sqlite")
        
        print("嘗試刪除數據庫文件: \(storeUrl.path)")
        
        // 嘗試刪除相關 Core Data 文件
        let filesToDelete = [
            storeUrl,
            storeUrl.appendingPathExtension("shm"),
            storeUrl.appendingPathExtension("wal")
        ]
        
        for url in filesToDelete {
            do {
                if fileManager.fileExists(atPath: url.path) {
                    try fileManager.removeItem(at: url)
                    print("已刪除: \(url.path)")
                } else {
                    print("文件不存在: \(url.path)")
                }
            } catch {
                print("刪除 \(url.path) 失敗: \(error.localizedDescription)")
            }
        }
        
        // 顯示重啟提示
        let alert = UIAlertController(
            title: "數據庫已重置",
            message: "請完全關閉應用並重新啟動。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    // 執行高級修復
    private func performAdvancedRepair() {
        // 檢查是否可以創建臨時內存數據庫
        let container = NSPersistentContainer(name: "TempContainer")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        // 嘗試載入
        container.loadPersistentStores { _, error in
            var message = "診斷結果:\n\n"
            
            if let error = error {
                message += "• 無法創建臨時數據庫: \(error.localizedDescription)\n"
            } else {
                message += "• 臨時數據庫創建成功\n"
            }
            
            // 檢查模型文件是否存在
            let modelURL = Bundle.main.url(forResource: "drivenote", withExtension: "momd")
            if modelURL != nil {
                message += "• 數據模型文件存在\n"
            } else {
                message += "• 數據模型文件不存在!\n"
            }
            
            // 檢查 SQLite 文件
            let fileManager = FileManager.default
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let storeUrl = documentsUrl.appendingPathComponent("drivenote.sqlite")
            
            if fileManager.fileExists(atPath: storeUrl.path) {
                message += "• SQLite 數據庫文件存在\n"
            } else {
                message += "• SQLite 數據庫文件不存在\n"
            }
            
            // 顯示診斷結果
            let alert = UIAlertController(
                title: "診斷結果",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    }
    
    // 這裡沒有額外的方法，刪除舊的未使用方法
}
