import Foundation
import Combine
import SwiftUI
import CoreData

/// 應用錯誤源
enum ErrorSource: String {
    case coreData = "核心數據"
    case viewModel = "視圖模型"
    case network = "網絡"
    case userInterface = "用戶界面"
    case fileSystem = "文件系統"
    case general = "通用"
}

/// 錯誤日誌條目
struct ErrorLogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let error: Error
    let source: ErrorSource
    let additionalInfo: [String: Any]?
    let isUserVisible: Bool
    let callStack: [String]
    
    init(error: Error, source: ErrorSource, additionalInfo: [String: Any]? = nil, isUserVisible: Bool = false) {
        self.date = Date()
        self.error = error
        self.source = source
        self.additionalInfo = additionalInfo
        self.isUserVisible = isUserVisible
        self.callStack = Thread.callStackSymbols
    }
}

/// 應用錯誤類型
struct AppError: Error, Identifiable {
    let id = UUID()
    let underlyingError: Error
    let source: ErrorSource
    let message: String
    let timestamp: Date
    let userVisible: Bool
    let autoRecoverable: Bool
    let recoveryAction: (() -> Void)?
    
    init(
        error: Error,
        source: ErrorSource,
        message: String? = nil,
        userVisible: Bool = false,
        autoRecoverable: Bool = false,
        recoveryAction: (() -> Void)? = nil
    ) {
        self.underlyingError = error
        self.source = source
        self.message = message ?? error.localizedDescription
        self.timestamp = Date()
        self.userVisible = userVisible
        self.autoRecoverable = autoRecoverable
        self.recoveryAction = recoveryAction
    }
}

/// 全局錯誤處理器
class ErrorHandler {
    static let shared = ErrorHandler()
    
    // 錯誤日誌
    private var errorLog: [ErrorLogEntry] = []
    private let maxLogEntries = 100
    
    // 發布者用於廣播錯誤
    private let errorSubject = PassthroughSubject<AppError, Never>()
    var errorPublisher: AnyPublisher<AppError, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    private init() {}
    
    // 處理錯誤
    func handle(_ error: Error, source: ErrorSource, additionalInfo: [String: Any]? = nil, isUserVisible: Bool = false, isRecoverable: Bool = false, recoveryAction: (() -> Void)? = nil) {
        // 創建應用錯誤
        let appError = AppError(
            error: error,
            source: source,
            userVisible: isUserVisible,
            autoRecoverable: isRecoverable,
            recoveryAction: recoveryAction
        )
        
        // 記錄錯誤
        logError(ErrorLogEntry(
            error: error,
            source: source,
            additionalInfo: additionalInfo,
            isUserVisible: isUserVisible
        ))
        
        // 如果需要，向用戶顯示錯誤
        if isUserVisible {
            errorSubject.send(appError)
        }
        
        // 嘗試自動恢復
        if isRecoverable, let recoveryAction = recoveryAction {
            performRecovery(action: recoveryAction)
        }
    }
    
    // 將常規錯誤轉換為應用錯誤
    func mapToAppError(_ error: Error, source: ErrorSource) -> AppError {
        // 根據錯誤類型和來源自定義錯誤消息和行為
        switch error {
        case let nsError as NSError where nsError.domain == NSCocoaErrorDomain && nsError.code == NSManagedObjectContextLockingError:
            return AppError(
                error: error,
                source: source,
                message: "數據庫訪問衝突，請稍後再試",
                userVisible: true,
                autoRecoverable: true
            )
            
        case let cdError as CoreDataManager.CoreDataError:
            return AppError(
                error: error,
                source: source,
                message: cdError.localizedDescription,
                userVisible: true,
                autoRecoverable: false
            )
            
        default:
            return AppError(
                error: error,
                source: source,
                userVisible: shouldShowErrorToUser(error, source: source),
                autoRecoverable: canAutomaticallyRecover(from: error, source: source)
            )
        }
    }
    
    // 記錄錯誤
    private func logError(_ entry: ErrorLogEntry) {
        errorLog.append(entry)
        
        // 限制日誌大小
        if errorLog.count > maxLogEntries {
            errorLog.removeFirst(errorLog.count - maxLogEntries)
        }
        
        // 打印到控制台
        print("==== DriveNote 錯誤 ====")
        print("時間: \(entry.date)")
        print("來源: \(entry.source.rawValue)")
        print("錯誤: \(entry.error.localizedDescription)")
        if let info = entry.additionalInfo, !info.isEmpty {
            print("附加信息: \(info)")
        }
        print("用戶可見: \(entry.isUserVisible ? "是" : "否")")
        print("調用堆棧:")
        for (index, symbol) in entry.callStack.enumerated().prefix(10) {
            print("  \(index): \(symbol)")
        }
        print("========================")
    }
    
    // 嘗試恢復
    private func performRecovery(action: @escaping () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }
    
    // 判斷是否應該向用戶顯示錯誤
    private func shouldShowErrorToUser(_ error: Error, source: ErrorSource) -> Bool {
        // 僅顯示嚴重錯誤或需要用戶操作的錯誤
        switch source {
        case .coreData:
            // 僅顯示嚴重的Core Data錯誤
            if let nsError = error as NSError? {
                return nsError.domain == NSCocoaErrorDomain && (
                    nsError.code == NSPersistentStoreIncompatibleVersionHashError ||
                    nsError.code == NSMigrationError ||
                    nsError.code == NSPersistentStoreIncompatibleSchemaError
                )
            }
            return false
            
        case .network:
            // 顯示需要用戶操作的網絡錯誤
            return true
            
        case .fileSystem:
            // 顯示關鍵的文件系統錯誤
            return true
            
        case .userInterface, .viewModel:
            // 僅顯示阻止用戶繼續的UI錯誤
            return false
            
        case .general:
            // 默認不顯示通用錯誤
            return false
        }
    }
    
    // 判斷是否可以自動恢復
    private func canAutomaticallyRecover(from error: Error, source: ErrorSource) -> Bool {
        // 判斷哪些錯誤可以自動嘗試恢復
        switch source {
        case .coreData:
            // 一些臨時的Core Data鎖定錯誤可以通過重試恢復
            if let nsError = error as NSError? {
                return nsError.domain == NSCocoaErrorDomain && (
                    nsError.code == NSManagedObjectContextLockingError ||
                    nsError.code == NSManagedObjectReferentialIntegrityError
                )
            }
            return false
            
        case .network:
            // 網絡超時可以自動重試
            return true
            
        case .fileSystem, .userInterface, .viewModel, .general:
            return false
        }
    }
    
    // 獲取錯誤日誌
    func getErrorLog() -> [ErrorLogEntry] {
        return errorLog
    }
    
    // 清除錯誤日誌
    func clearErrorLog() {
        errorLog.removeAll()
    }
}

// MARK: - 視圖模型與UI 整合

/// 錯誤視圖模型
class ErrorViewModel: ObservableObject {
    @Published var currentError: AppError?
    
    private var cancellable: AnyCancellable?
    
    func startListening() {
        cancellable = ErrorHandler.shared.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.currentError = error
            }
    }
    
    func stopListening() {
        cancellable?.cancel()
        cancellable = nil
    }
    
    func dismiss() {
        currentError = nil
    }
}

/// 錯誤處理視圖修飾器
struct ErrorHandlingViewModifier: ViewModifier {
    @StateObject private var errorModel = ErrorViewModel()
    
    func body(content: Content) -> some View {
        content
            .environmentObject(errorModel)
            .onAppear {
                errorModel.startListening()
            }
            .onDisappear {
                errorModel.stopListening()
            }
            .overlay(
                Group {
                    if let error = errorModel.currentError {
                        ErrorToastView(error: error) {
                            errorModel.dismiss()
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(), value: errorModel.currentError != nil)
                    }
                }
            )
    }
}

/// 錯誤提示視圖
struct ErrorToastView: View {
    let error: AppError
    let dismissAction: () -> Void
    
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                
                Text(error.source.rawValue + "錯誤")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: dismissAction) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Text(error.message)
                .font(.subheadline)
                .foregroundColor(.white)
            
            if let recoveryAction = error.recoveryAction {
                Button(action: {
                    recoveryAction()
                    dismissAction()
                }) {
                    Text("嘗試修復")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 顯示詳細信息的可折疊部分
            Button(action: {
                withAnimation {
                    showDetails.toggle()
                }
            }) {
                HStack {
                    Text(showDetails ? "隱藏詳情" : "顯示詳情")
                        .font(.caption)
                    
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.white.opacity(0.7))
            }
            
            if showDetails {
                Text("錯誤: \(error.underlyingError.localizedDescription)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("時間: \(error.timestamp.formatted())")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.9))
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding()
    }
}

// MARK: - View 擴展

extension View {
    /// 添加全局錯誤處理
    func withErrorHandling() -> some View {
        self.modifier(ErrorHandlingViewModifier())
    }
}
