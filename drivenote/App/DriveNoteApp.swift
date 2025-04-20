import SwiftUI
import CoreData
import Combine

// MARK: - 應用狀態管理
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isDataStoreReady = false
    @Published var initializationError: Error? = nil
    @Published var isInitializing = false
    @Published var diagnosticMessage = "準備初始化..."
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func initializeDataStore() {
        guard !isInitializing else { return }
        
        isInitializing = true
        diagnosticMessage = "正在初始化數據存儲..."
        
        // 延遲一點初始化，讓UI有時間渲染
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.performInitialization()
        }
    }
    
    private func performInitialization() {
        // 嘗試初始化 Core Data 堆棧
        CoreDataManager.shared.initializeStack()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isInitializing = false
                    
                    if case .failure(let error) = completion {
                        self?.handleInitializationError(error)
                    }
                },
                receiveValue: { [weak self] success in
                    self?.diagnosticMessage = "數據存儲初始化成功!"
                    self?.isDataStoreReady = success
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleInitializationError(_ error: Error) {
        initializationError = error
        diagnosticMessage = "初始化失敗: \(error.localizedDescription)"
        
        // 嘗試使用內存數據庫作為備用選項
        print("嘗試使用內存數據庫作為備用...")
        diagnosticMessage = "嘗試使用臨時數據庫..."
        
        CoreDataManager.shared.initializeInMemoryStore()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.diagnosticMessage = "無法創建臨時數據庫: \(error.localizedDescription)"
                        // 完全失敗，保持 isDataStoreReady = false
                    }
                },
                receiveValue: { [weak self] success in
                    if success {
                        self?.diagnosticMessage = "已創建臨時數據庫 (數據不會永久保存)"
                        self?.isDataStoreReady = true
                    }
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - 應用初始化視圖
struct AppInitializationView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showDiagnosticOptions = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 頂部圖標和標題
            VStack(spacing: 12) {
                Image(systemName: appState.initializationError != nil ? "exclamationmark.triangle.fill" : "arrow.clockwise.circle")
                    .font(.system(size: 60))
                    .foregroundColor(appState.initializationError != nil ? .orange : .blue)
                    .padding()
                
                Text("DriveNote")
                    .font(.largeTitle)
                    .bold()
                
                Text(appState.initializationError != nil ? "啟動診斷" : "應用程序初始化")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // 狀態信息
            VStack(spacing: 8) {
                if appState.isInitializing {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                }
                
                Text(appState.diagnosticMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .animation(.easeInOut, value: appState.diagnosticMessage)
            }
            .frame(height: 100)
            
            // 操作按鈕
            VStack(spacing: 12) {
                // 顯示當啟動失敗時
                if appState.initializationError != nil {
                    Button(action: {
                        appState.initializeDataStore()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("重試")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showDiagnosticOptions = true
                    }) {
                        HStack {
                            Image(systemName: "wrench.and.screwdriver")
                            Text("診斷選項")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .actionSheet(isPresented: $showDiagnosticOptions) {
                        ActionSheet(
                            title: Text("診斷選項"),
                            message: Text("選擇一個操作來嘗試修復應用"),
                            buttons: [
                                .default(Text("使用臨時數據庫")) {
                                    createTempDatabase()
                                },
                                .destructive(Text("重置數據庫")) {
                                    resetDatabase()
                                },
                                .cancel()
                            ]
                        )
                    }
                }
                
                // 當成功使用臨時數據庫時顯示
                if appState.isDataStoreReady && appState.initializationError != nil {
                    Button(action: {
                        // 強制進入應用，使用臨時數據庫
                        appState.isDataStoreReady = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle")
                            Text("繼續使用臨時數據庫")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 底部提示
            if appState.initializationError != nil {
                Text("數據可能無法永久保存，請先嘗試修復")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if !appState.isInitializing && !appState.isDataStoreReady {
                appState.initializeDataStore()
            }
        }
    }
    
    // 創建臨時數據庫
    private func createTempDatabase() {
        appState.diagnosticMessage = "創建臨時數據庫中..."
        
        CoreDataManager.shared.initializeInMemoryStore()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        appState.diagnosticMessage = "創建臨時數據庫失敗: \(error.localizedDescription)"
                    }
                },
                receiveValue: { success in
                    if success {
                        appState.diagnosticMessage = "臨時數據庫創建成功"
                        appState.isDataStoreReady = true
                    } else {
                        appState.diagnosticMessage = "臨時數據庫創建失敗"
                    }
                }
            )
            .store(in: &CoreDataManager.shared.cancellables)
    }
    
    // 重置數據庫
    private func resetDatabase() {
        appState.diagnosticMessage = "正在重置數據庫..."
        
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
                    appState.diagnosticMessage = "刪除 \(url.lastPathComponent) 失敗: \(error.localizedDescription)"
                    success = false
                    break
                }
            }
        }
        
        if success {
            appState.diagnosticMessage = "數據庫已重置，正在重新初始化..."
            
            // 延遲一下再重新初始化
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                appState.initializationError = nil
                appState.isDataStoreReady = false
                appState.initializeDataStore()
            }
        }
    }
}

// MARK: - 應用主入口點
@main
struct DriveNoteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            if appState.isDataStoreReady {
                // 正常模式 - 顯示主要內容
                ContentView()
                    .environmentObject(appState)
            } else {
                // 安全模式 - 顯示初始化界面
                AppInitializationView()
                    .environmentObject(appState)
            }
        }
    }
}
