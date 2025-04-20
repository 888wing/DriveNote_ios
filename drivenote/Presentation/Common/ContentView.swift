import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = 0
    @State private var showDebugTools = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 儀表板頁面
            SafeView {
                DashboardView()
            }
            .tabItem {
                Label("儀表板", systemImage: "chart.bar.fill")
            }
            .tag(0)
            
            // 支出頁面
            SafeView {
                ExpensesView()
            }
            .tabItem {
                Label("支出", systemImage: "creditcard.fill")
            }
            .tag(1)
            
            // 里程頁面
            SafeView {
                MileageView()
            }
            .tabItem {
                Label("里程", systemImage: "car.fill")
            }
            .tag(2)
            
            // 工時頁面
            SafeView {
                WorkHoursView()
            }
            .tabItem {
                Label("工時", systemImage: "clock.fill")
            }
            .tag(3)
            
            // 設置頁面
            SafeView {
                SettingsView()
            }
            .tabItem {
                Label("設置", systemImage: "ellipsis.circle.fill")
            }
            .tag(4)
        }
        .overlay(alignment: .top) {
            if showDebugTools {
                DebugToolbar(selectedTab: $selectedTab, appState: appState)
                    .transition(.move(edge: .top))
                    .animation(.spring(), value: showDebugTools)
            }
        }
        .onShake {
            // 使用搖動手勢顯示調試工具
            withAnimation {
                showDebugTools.toggle()
            }
        }
        .onAppear {
            print("ContentView: Tab Bar 已加載")
            
            // 如果使用內存數據庫，顯示一個提示
            if CoreDataManager.shared.isUsingInMemoryStore {
                showMemoryStoreWarning()
            }
        }
    }
    
    private func showMemoryStoreWarning() {
        let alert = UIAlertController(
            title: "使用臨時數據庫",
            message: "應用正在使用臨時內存數據庫。您的數據將不會被永久保存。請在設置中嘗試修復數據庫。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}

// MARK: - SafeView

/// 安全視圖包裝器，防止子視圖的錯誤影響整個應用
struct SafeView<Content: View>: View {
    let content: () -> Content
    
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var errorStack = ""
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        if hasError {
            // 顯示錯誤恢復界面
            ErrorView(message: errorMessage, stack: errorStack) {
                // 重置錯誤狀態
                hasError = false
            }
        } else {
            content()
                .onCatch { error in
                    hasError = true
                    errorMessage = error.localizedDescription
                    errorStack = Thread.callStackSymbols.joined(separator: "\n")
                }
        }
    }
}

// MARK: - ErrorView

/// 錯誤恢復界面
struct ErrorView: View {
    let message: String
    let stack: String
    let retryAction: () -> Void
    
    @State private var showDetails = false
    
    init(message: String, stack: String = "", retryAction: @escaping () -> Void) {
        self.message = message
        self.stack = stack
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("視圖載入錯誤")
                .font(.title)
                .bold()
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if !stack.isEmpty {
                Button("顯示技術細節") {
                    showDetails.toggle()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(8)
                
                if showDetails {
                    ScrollView {
                        Text(stack)
                            .font(.caption)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 200)
                    .padding(.horizontal)
                }
            }
            
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("重試")
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - DebugToolbar

/// 調試工具欄
struct DebugToolbar: View {
    @Binding var selectedTab: Int
    let appState: AppState
    
    @State private var showDiagnostics = false
    
    var body: some View {
        HStack {
            Button(action: {
                // 重新加載當前標籤
                let current = selectedTab
                selectedTab = -1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = current
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(width: 40, height: 40)
            .background(Color.primary.opacity(0.1))
            .clipShape(Circle())
            
            Spacer()
            
            Text("調試模式")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                showDiagnostics = true
            }) {
                Image(systemName: "info.circle")
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(width: 40, height: 40)
            .background(Color.primary.opacity(0.1))
            .clipShape(Circle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .padding(.top, 8)
        .sheet(isPresented: $showDiagnostics) {
            DiagnosticsView(appState: appState)
        }
    }
}

/// 診斷視圖
struct DiagnosticsView: View {
    let appState: AppState
    
    @State private var deviceInfo = [String: String]()
    @State private var coreDataStatus = [String: String]()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("應用狀態")) {
                    InfoRow(title: "數據存儲狀態", value: appState.isDataStoreReady ? "就緒" : "未初始化")
                    InfoRow(title: "存儲類型", value: CoreDataManager.shared.isUsingInMemoryStore ? "內存臨時存儲" : "持久化存儲")
                    
                    if let error = appState.initializationError {
                        InfoRow(title: "初始化錯誤", value: error.localizedDescription)
                    }
                }
                
                Section(header: Text("設備信息")) {
                    ForEach(deviceInfo.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        InfoRow(title: key, value: value)
                    }
                }
                
                Section(header: Text("Core Data 狀態")) {
                    ForEach(coreDataStatus.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        InfoRow(title: key, value: value)
                    }
                }
                
                Section(header: Text("操作")) {
                    Button("分析數據庫狀態") {
                        analyzeDatabase()
                    }
                    
                    Button("重置數據庫") {
                        resetDatabase()
                    }
                    .foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("診斷信息")
            .navigationBarItems(trailing: Button("關閉") {
                // 由 sheet 處理關閉
            })
            .onAppear {
                loadDeviceInfo()
                analyzeCoreDataStatus()
            }
        }
    }
    
    private func loadDeviceInfo() {
        deviceInfo["iOS 版本"] = UIDevice.current.systemVersion
        deviceInfo["設備名稱"] = UIDevice.current.name
        deviceInfo["設備型號"] = UIDevice.current.model
        deviceInfo["系統名稱"] = UIDevice.current.systemName
        
        // 獲取可用存儲空間
        do {
            let fileURL = URL(fileURLWithPath: NSHomeDirectory())
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let capacity = values.volumeAvailableCapacityForImportantUsage {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useGB]
                formatter.countStyle = .file
                deviceInfo["可用空間"] = formatter.string(fromByteCount: Int64(capacity))
            }
        } catch {
            deviceInfo["可用空間"] = "無法獲取: \(error.localizedDescription)"
        }
        
        // 獲取 App 版本
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            deviceInfo["App 版本"] = "\(appVersion) (\(buildNumber))"
        }
    }
    
    private func analyzeCoreDataStatus() {
        coreDataStatus["初始化狀態"] = CoreDataManager.shared.isInitialized ? "已初始化" : "未初始化"
        coreDataStatus["存儲類型"] = CoreDataManager.shared.isUsingInMemoryStore ? "內存臨時存儲" : "持久化存儲"
        
        // 檢查模型文件
        if let modelURL = Bundle.main.url(forResource: "drivenote", withExtension: "momd") {
            coreDataStatus["模型文件"] = "存在 (\(modelURL.lastPathComponent))"
        } else {
            coreDataStatus["模型文件"] = "不存在 (⚠️)"
        }
        
        // 檢查數據庫文件
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let storeUrl = documentsUrl.appendingPathComponent("drivenote.sqlite")
        
        if fileManager.fileExists(atPath: storeUrl.path) {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: storeUrl.path)
                if let size = attributes[.size] as? Int64,
                   let date = attributes[.modificationDate] as? Date {
                    let formatter = ByteCountFormatter()
                    formatter.countStyle = .file
                    
                    coreDataStatus["SQLite 文件"] = "存在 (\(formatter.string(fromByteCount: size)))"
                    coreDataStatus["上次修改"] = date.formatted()
                }
            } catch {
                coreDataStatus["SQLite 文件"] = "存在 (無法讀取屬性)"
            }
        } else {
            coreDataStatus["SQLite 文件"] = "不存在"
        }
    }
    
    private func analyzeDatabase() {
        CoreDataManager.shared.analyzeDatabaseIssues()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        coreDataStatus["分析結果"] = "分析失敗: \(error.localizedDescription)"
                    }
                },
                receiveValue: { diagInfo in
                    for (key, value) in diagInfo {
                        coreDataStatus[key] = "\(value)"
                    }
                }
            )
            .store(in: &CoreDataManager.shared.cancellables)
    }
    
    private func resetDatabase() {
        CoreDataManager.shared.removeExistingStoreFiles()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        coreDataStatus["重置結果"] = "重置失敗: \(error.localizedDescription)"
                    }
                },
                receiveValue: { success in
                    coreDataStatus["重置結果"] = success ? "重置成功，需要重啟應用" : "重置失敗"
                    
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
            )
            .store(in: &CoreDataManager.shared.cancellables)
    }
}

/// 簡單信息行
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Error Catching

/// ViewModifier 用於捕獲錯誤
struct ErrorCatcher: ViewModifier {
    @Binding var hasError: Bool
    let handler: (Error) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                ErrorCatchingView(hasError: $hasError, handler: handler)
            )
    }
}

/// 捕獲錯誤的輔助視圖
struct ErrorCatchingView: UIViewControllerRepresentable {
    @Binding var hasError: Bool
    let handler: (Error) -> Void
    
    func makeUIViewController(context: Context) -> ErrorCatchingViewController {
        ErrorCatchingViewController(handler: { error in
            hasError = true
            handler(error)
        })
    }
    
    func updateUIViewController(_ uiViewController: ErrorCatchingViewController, context: Context) {
        // 無需更新
    }
}

/// 捕獲錯誤的控制器
class ErrorCatchingViewController: UIViewController {
    let handler: (Error) -> Void
    
    init(handler: @escaping (Error) -> Void) {
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
}

// MARK: - Extensions

/// 為 View 添加捕獲錯誤的擴展
extension View {
    func onCatch(handler: @escaping (Error) -> Void) -> some View {
        modifier(ErrorCatcher(hasError: .constant(false), handler: handler))
    }
}

/// 添加搖動手勢
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}

struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState.shared)
    }
}
