import SwiftUI

struct ContentView: View {
    @State private var selection = 4 // 默認選擇設置頁面
    @State private var showDebug = false
    
    var body: some View {
        TabView(selection: $selection) {
            // 直接顯示設置頁面，其他頁面暫時不啟用，以防止 Core Data 崩潰
            Text("儀表板正在開發中")
                .tabItem {
                    Label("儀表板", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            Text("支出記錄正在開發中")
                .tabItem {
                    Label("支出", systemImage: "creditcard.fill")
                }
                .tag(1)
            
            Text("里程記錄正在開發中")
                .tabItem {
                    Label("里程", systemImage: "car.fill")
                }
                .tag(2)
            
            Text("工時記錄正在開發中")
                .tabItem {
                    Label("工時", systemImage: "clock.fill")
                }
                .tag(3)
            
            // 只啟用設置頁面，因為它可能不直接依賴 Core Data
            SettingsView()
                .tabItem {
                    Label("設置", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .onAppear {
            print("ContentView: 頁面出現")
        }
        // 添加調試按鈕
        .overlay(alignment: .topTrailing) {
            if showDebug {
                Button(action: {
                    // 重置選擇的索引，強制重新載入當前頁面
                    let current = selection
                    selection = -1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        selection = current
                    }
                }) {
                    Text("重載")
                        .font(.caption)
                        .padding(5)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .padding(5)
            }
        }
        // 添加三指長按觸發調試模式的手勢
        .onLongPressGesture(minimumDuration: 2, maximumDistance: 50) {
            showDebug.toggle()
        }
    }
}

// 安全視圖包裝器，防止子視圖的錯誤影響整個應用
struct SafeView<Content: View>: View {
    let content: () -> Content
    @State private var hasError = false
    @State private var errorMessage: String = ""
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        if hasError {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                
                Text("視圖載入錯誤")
                    .font(.headline)
                
                Text(errorMessage)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Button("重試") {
                    hasError = false
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        } else {
            content()
                .onCatch { error in
                    hasError = true
                    errorMessage = error.localizedDescription
                }
        }
    }
}

// ViewModifier 用於捕獲錯誤
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

// 捕獲錯誤的輔助視圖
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

// 捕獲錯誤的控制器
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

// 為 View 添加捕獲錯誤的擴展
extension View {
    func onCatch(handler: @escaping (Error) -> Void) -> some View {
        modifier(ErrorCatcher(hasError: .constant(false), handler: handler))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
