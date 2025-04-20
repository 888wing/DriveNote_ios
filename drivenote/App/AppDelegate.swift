import UIKit
import CoreData
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
    var cancellables = Set<AnyCancellable>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 配置應用程序
        configureApp()
        
        // 設置日誌和錯誤處理
        setupLogging()
        
        print("AppDelegate: 應用程序啟動完成")
        return true
    }
    
    private func configureApp() {
        // 配置 UserDefaults 默認值
        setupDefaultSettings()
        
        // 配置外觀
        configureAppearance()
        
        // 配置通知 (如果需要)
        // setupNotifications()
        
        // 禁用「返回」手勢 (如果需要)
        // UINavigationController.disableSwipeBackGesture()
    }
    
    private func setupDefaultSettings() {
        // 設置默認偏好
        let defaults: [String: Any] = [
            "currencyCode": "GBP",
            "distanceUnit": "miles",
            "syncEnabled": false,
            "isFirstLaunch": true,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]
        
        UserDefaults.standard.register(defaults: defaults)
    }
    
    private func configureAppearance() {
        // 配置全局 UI 外觀
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    private func setupLogging() {
        // 設置日誌系統
        print("AppDelegate: 初始化日誌系統")
        
        // 捕獲未處理的異常
        NSSetUncaughtExceptionHandler { exception in
            print("未捕獲的異常: \(exception)")
            print("原因: \(String(describing: exception.reason))")
            print("調用堆棧: \(exception.callStackSymbols)")
            
            // 將NSException轉化為NSError
            let error = NSError(
                domain: "UncaughtException",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: exception.reason ?? "未知異常",
                    "ExceptionName": exception.name.rawValue,
                    "CallStack": exception.callStackSymbols
                ]
            )
            
            // 記錄到我們的錯誤處理器
            ErrorHandler.shared.handle(
                error,
                source: .general,
                additionalInfo: ["callStack": exception.callStackSymbols],
                isUserVisible: true
            )
        }
    }
    
    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 場景被丟棄時調用，例如用戶關閉多個窗口
    }
}
