import Foundation
import Combine
import SwiftUI

/// 視圖狀態
enum ViewState<T> {
    case loading
    case loaded(T)
    case empty
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var value: T? {
        if case .loaded(let value) = self {
            return value
        }
        return nil
    }
    
    var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
    
    var isEmpty: Bool {
        if case .empty = self {
            return true
        }
        return false
    }
}

/// 視圖模型基類
class BaseViewModel: ObservableObject {
    /// 用於取消訂閱
    var cancellables = Set<AnyCancellable>()
    
    /// 處理錯誤
    func handleError(_ error: Error, source: ErrorSource = .viewModel, isUserVisible: Bool = false) {
        // 記錄錯誤
        print("ViewModel Error: \(error.localizedDescription)")
        
        // 將錯誤轉發給全局錯誤處理器
        ErrorHandler.shared.handle(
            error,
            source: source,
            isUserVisible: isUserVisible,
            isRecoverable: canRecoverFromError(error)
        ) { [weak self] in
            self?.attemptRecovery(from: error)
        }
    }
    
    /// 判斷是否可以從錯誤中恢復
    func canRecoverFromError(_ error: Error) -> Bool {
        // 默認實現 - 子類可以重寫
        return false
    }
    
    /// 嘗試從錯誤中恢復
    func attemptRecovery(from error: Error) {
        // 默認實現 - 子類可以重寫
        print("嘗試從錯誤中恢復: \(error.localizedDescription)")
    }
    
    /// 延遲調用 (例如防抖動)
    func debounce(interval: TimeInterval = 0.5, action: @escaping () -> Void) -> () -> Void {
        var lastFireTime = Date(timeIntervalSince1970: 0)
        let dispatchDelay = DispatchTimeInterval.milliseconds(Int(interval * 1000))
        
        return {
            lastFireTime = Date()
            let dispatchTime: DispatchTime = .now() + dispatchDelay
            
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) { [lastFireTime] in
                let now = Date()
                let when = lastFireTime.addingTimeInterval(interval)
                if now.compare(when) != .orderedAscending {
                    action()
                }
            }
        }
    }
    
    /// 預加載資源
    func preloadResources() {
        // 默認實現 - 子類可以重寫
    }
    
    /// 釋放資源
    func cleanUp() {
        cancellables.removeAll()
    }
    
    deinit {
        cleanUp()
        print("\(String(describing: type(of: self))) deinit")
    }
}

/// 狀態處理視圖模型基類
class StatefulViewModel<T>: BaseViewModel {
    /// 視圖狀態
    @Published var state: ViewState<T> = .loading
    
    /// 更新為加載狀態
    func setLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.state = .loading
        }
    }
    
    /// 更新為已加載狀態
    func setLoaded(_ value: T) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .loaded(value)
        }
    }
    
    /// 更新為空狀態
    func setEmpty() {
        DispatchQueue.main.async { [weak self] in
            self?.state = .empty
        }
    }
    
    /// 更新為錯誤狀態
    func setError(_ error: Error) {
        handleError(error)
        
        DispatchQueue.main.async { [weak self] in
            self?.state = .error(error)
        }
    }
}

/// 統一的視圖狀態處理組件
struct ViewStateHandler<Content: View, Data>: View {
    let state: ViewState<Data>
    let content: (Data) -> Content
    var loadingView: AnyView? = nil
    var emptyView: AnyView? = nil
    // 明確將 retry 參數標記為 @escaping
    var errorView: ((Error, @escaping () -> Void) -> AnyView)? = nil 
    var retry: (() -> Void)? = nil
    
    var body: some View {
        // 創建一個本地的、安全逃逸的重試閉包
        let safeRetry: (() -> Void)? = retry.map { retry in
            return { retry() }
        }
        
        switch state {
        case .loading:
            if let loadingView = loadingView {
                loadingView
            } else {
                ProgressView("加載中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
        case .loaded(let data):
            content(data)
            
        case .empty:
            if let emptyView = emptyView {
                emptyView
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("無數據")
                        .font(.headline)
                    
                    if let safeRetry = safeRetry {
                        Button(action: safeRetry) {
                            Text("重新加載")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
        case .error(let error):
            if let errorView = errorView, let safeRetry = safeRetry {
                errorView(error, safeRetry)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("加載數據時出現錯誤")
                        .font(.headline)
                    
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if let safeRetry = safeRetry {
                        Button(action: safeRetry) {
                            Text("重試")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// 構建器方法
extension ViewStateHandler {
    func loading<LoadingView: View>(@ViewBuilder _ view: @escaping () -> LoadingView) -> Self {
        var copy = self
        copy.loadingView = AnyView(view())
        return copy
    }
    
    func empty<EmptyView: View>(@ViewBuilder _ view: @escaping () -> EmptyView) -> Self {
        var copy = self
        copy.emptyView = AnyView(view())
        return copy
    }
    
    func error<ErrorView: View>(@ViewBuilder _ view: @escaping (Error, @escaping () -> Void) -> ErrorView) -> Self {
        var copy = self
        copy.errorView = { error, retry in
            AnyView(view(error, retry))
        }
        return copy
    }
    
    func onRetry(_ retry: @escaping () -> Void) -> Self {
        var copy = self
        copy.retry = retry
        return copy
    }
}
