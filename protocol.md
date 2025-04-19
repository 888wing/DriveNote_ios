# DriveNote iOS - 編碼框架及協議文檔

## 1. 架構概覽

DriveNote iOS應用將採用Clean Architecture(乾淨架構)與MVVM(Model-View-ViewModel)設計模式的結合，讓代碼更易於測試、維護和擴展。這特別適合一個需要離線優先設計的MVP產品。

### 1.1 整體架構圖

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│                 │      │                 │      │                 │
│  Presentation   │◄────►│    Domain       │◄────►│     Data        │
│     Layer       │      │     Layer       │      │     Layer       │
│                 │      │                 │      │                 │
└─────────────────┘      └─────────────────┘      └─────────────────┘
       │                                                  │
       │                                                  │
       ▼                                                  ▼
┌─────────────────┐                             ┌─────────────────┐
│   UI (SwiftUI)  │                             │   Core Data     │
│   ViewModels    │                             │   Firebase      │
└─────────────────┘                             │   Gemini API    │
                                                └─────────────────┘
```

### 1.2 架構層級說明

1. **Presentation Layer**
   - 包含所有UI元素和ViewModels
   - 使用SwiftUI實現界面
   - 遵循MVVM模式組織代碼

2. **Domain Layer**
   - 包含業務邏輯和用例(UseCases)
   - 定義業務實體(Entities)
   - 定義Repository接口(Protocols)

3. **Data Layer**
   - 包含數據源實現(Local和Remote)
   - Repository實現類
   - Core Data和Firebase管理器

## 2. 目錄結構

```
DriveNote/
├── App/
│   ├── DriveNoteApp.swift           # 應用入口點
│   └── AppDelegate.swift            # 應用代理
├── Presentation/
│   ├── Common/                      # 共用UI組件
│   ├── Dashboard/                   # 儀表板模塊
│   ├── Expenses/                    # 支出記錄模塊
│   ├── Mileage/                     # 里程記錄模塊
│   ├── WorkHours/                   # 工時記錄模塊
│   ├── Income/                      # 收入記錄模塊
│   ├── Reports/                     # 報告模塊
│   └── Settings/                    # 設置模塊
├── Domain/
│   ├── Entities/                    # 業務實體
│   ├── UseCases/                    # 用例
│   └── Repositories/                # 存儲庫接口
├── Data/
│   ├── CoreData/                    # 本地數據存儲
│   │   ├── Model/                   # Core Data模型
│   │   └── Manager/                 # Core Data管理
│   ├── Firebase/                    # Firebase集成
│   │   ├── Auth/                    # 認證服務
│   │   ├── Firestore/               # 雲數據庫
│   │   └── Storage/                 # 雲存儲
│   ├── Network/                     # 網絡請求
│   │   └── OCR/                     # OCR服務
│   └── Repositories/                # 存儲庫實現
└── Resources/                       # 資源文件
    ├── Info.plist
    ├── Assets.xcassets
    └── LaunchScreen.storyboard
```

## 3. 數據模型

### 3.1 Core Data 實體

#### 3.1.1 Expense (支出)
```swift
entity Expense {
    uuid: UUID                  // 唯一標識
    date: Date                  // 支出日期
    amount: Decimal             // 金額
    category: String            // 類別
    description: String?        // 描述
    isTaxDeductible: Bool       // 是否可抵稅
    taxDeductiblePercentage: Int// 可抵稅比例
    creationMethod: String      // 創建方式 (manual/ocr)
    isUploaded: Bool            // 是否已上傳至雲端
    lastModified: Date          // 最後修改時間
    
    // 關聯
    receipts: [Receipt]         // 關聯收據
    relatedMileage: Mileage?    // 關聯里程記錄
}
```

#### 3.1.2 Receipt (收據)
```swift
entity Receipt {
    uuid: UUID                  // 唯一標識
    filePath: String            // 文件路徑
    uploadTimestamp: Date       // 上傳時間
    ocrStatus: String           // OCR狀態 (pending/processing/completed/failed)
    ocrResultJson: String?      // OCR結果JSON
    isUploaded: Bool            // 是否已上傳至雲端
    
    // 關聯
    expense: Expense?           // 關聯支出
}
```

#### 3.1.3 Mileage (里程)
```swift
entity Mileage {
    uuid: UUID                  // 唯一標識
    date: Date                  // 日期
    startMileage: Double?       // 起始里程數
    endMileage: Double?         // 結束里程數
    distance: Double            // 總里程
    purpose: String?            // 行程目的
    isUploaded: Bool            // 是否已上傳至雲端
    lastModified: Date          // 最後修改時間
    
    // 關聯
    relatedFuelExpense: Expense?// 關聯燃料支出
}
```

#### 3.1.4 WorkHours (工時)
```swift
entity WorkHours {
    uuid: UUID                  // 唯一標識
    date: Date                  // 日期
    startTime: Date?            // 開始時間
    endTime: Date?              // 結束時間
    totalHours: Double          // 總工時
    isUploaded: Bool            // 是否已上傳至雲端
    lastModified: Date          // 最後修改時間
}
```

#### 3.1.5 Income (收入)
```swift
entity Income {
    uuid: UUID                  // 唯一標識
    date: Date                  // 日期
    amount: Decimal             // 金額
    tipAmount: Decimal          // 小費金額
    source: String              // 收入來源 (Uber/其他)
    notes: String?              // 備註
    isUploaded: Bool            // 是否已上傳至雲端
    lastModified: Date          // 最後修改時間
}
```

#### 3.1.6 Settings (設置)
```swift
entity Settings {
    uuid: UUID                  // 唯一標識
    deviceId: String            // 設備ID
    userId: String?             // 用戶ID (可選)
    syncEnabled: Bool           // 是否啟用同步
    currencyCode: String        // 貨幣代碼 (預設GBP)
    distanceUnit: String        // 距離單位 (預設miles)
    lastSyncTime: Date?         // 最後同步時間
}
```

### 3.2 Firebase 數據結構

#### 3.2.1 Firestore 集合設計
```
users/
└── {userId}/
    ├── profile/                 # 用戶資料
    ├── expenses/                # 支出記錄
    │   └── {expenseId}/         
    ├── receipts/                # 收據記錄
    │   └── {receiptId}/         
    ├── mileage/                 # 里程記錄
    │   └── {mileageId}/         
    ├── workHours/               # 工時記錄
    │   └── {workHoursId}/       
    └── income/                  # 收入記錄
        └── {incomeId}/          
```

#### 3.2.2 Firebase Storage 結構
```
receipts/{userId}/{yyyy-MM}/{receiptId}.{ext}
```

## 4. 協議定義

### 4.1 數據儲存庫協議

#### 4.1.1 ExpenseRepository
```swift
protocol ExpenseRepository {
    func getAllExpenses() -> AnyPublisher<[Expense], Error>
    func getExpenseById(id: UUID) -> AnyPublisher<Expense?, Error>
    func getExpensesByDateRange(start: Date, end: Date) -> AnyPublisher<[Expense], Error>
    func saveExpense(expense: Expense) -> AnyPublisher<Expense, Error>
    func deleteExpense(id: UUID) -> AnyPublisher<Void, Error>
    func syncExpenses() -> AnyPublisher<Void, Error>
}
```

#### 4.1.2 MileageRepository
```swift
protocol MileageRepository {
    func getAllMileage() -> AnyPublisher<[Mileage], Error>
    func getMileageById(id: UUID) -> AnyPublisher<Mileage?, Error>
    func getMileageByDateRange(start: Date, end: Date) -> AnyPublisher<[Mileage], Error>
    func saveMileage(mileage: Mileage) -> AnyPublisher<Mileage, Error>
    func deleteMileage(id: UUID) -> AnyPublisher<Void, Error>
    func syncMileage() -> AnyPublisher<Void, Error>
}
```

#### 4.1.3 WorkHoursRepository
```swift
protocol WorkHoursRepository {
    func getAllWorkHours() -> AnyPublisher<[WorkHours], Error>
    func getWorkHoursById(id: UUID) -> AnyPublisher<WorkHours?, Error>
    func getWorkHoursByDateRange(start: Date, end: Date) -> AnyPublisher<[WorkHours], Error>
    func saveWorkHours(workHours: WorkHours) -> AnyPublisher<WorkHours, Error>
    func deleteWorkHours(id: UUID) -> AnyPublisher<Void, Error>
    func syncWorkHours() -> AnyPublisher<Void, Error>
}
```

#### 4.1.4 ReceiptRepository
```swift
protocol ReceiptRepository {
    func getAllReceipts() -> AnyPublisher<[Receipt], Error>
    func getReceiptById(id: UUID) -> AnyPublisher<Receipt?, Error>
    func saveReceipt(receipt: Receipt, imageData: Data) -> AnyPublisher<Receipt, Error>
    func deleteReceipt(id: UUID) -> AnyPublisher<Void, Error>
    func processReceiptWithOCR(receipt: Receipt) -> AnyPublisher<Receipt, Error>
    func syncReceipts() -> AnyPublisher<Void, Error>
}
```

#### 4.1.5 IncomeRepository
```swift
protocol IncomeRepository {
    func getAllIncome() -> AnyPublisher<[Income], Error>
    func getIncomeById(id: UUID) -> AnyPublisher<Income?, Error>
    func getIncomeByDateRange(start: Date, end: Date) -> AnyPublisher<[Income], Error>
    func saveIncome(income: Income) -> AnyPublisher<Income, Error>
    func deleteIncome(id: UUID) -> AnyPublisher<Void, Error>
    func syncIncome() -> AnyPublisher<Void, Error>
}
```

### 4.2 服務協議

#### 4.2.1 OCRService
```swift
protocol OCRService {
    func analyzeReceiptImage(imageData: Data) -> AnyPublisher<OCRResult, Error>
}
```

#### 4.2.2 AuthService
```swift
protocol AuthService {
    func getCurrentUserId() -> String?
    func isUserLoggedIn() -> Bool
    func loginAnonymously() -> AnyPublisher<String, Error>
    func loginWithApple() -> AnyPublisher<String, Error>
    func logout() -> AnyPublisher<Void, Error>
}
```

#### 4.2.3 SyncService
```swift
protocol SyncService {
    func syncAllData() -> AnyPublisher<Void, Error>
    func getSyncStatus() -> AnyPublisher<SyncStatus, Never>
}
```

## 5. 用例(Use Cases)定義

### 5.1 支出相關用例
```swift
struct SaveExpenseUseCase {
    let repository: ExpenseRepository
    
    func execute(expense: Expense) -> AnyPublisher<Expense, Error>
}

struct GetExpensesUseCase {
    let repository: ExpenseRepository
    
    func execute(dateRange: DateRange? = nil) -> AnyPublisher<[Expense], Error>
}

struct AnalyzeExpensesUseCase {
    let repository: ExpenseRepository
    
    func execute(dateRange: DateRange) -> AnyPublisher<ExpenseAnalytics, Error>
}
```

### 5.2 里程相關用例
```swift
struct SaveMileageUseCase {
    let repository: MileageRepository
    
    func execute(mileage: Mileage) -> AnyPublisher<Mileage, Error>
}

struct CalculateMileageCostUseCase {
    let mileageRepository: MileageRepository
    let expenseRepository: ExpenseRepository
    
    func execute(dateRange: DateRange) -> AnyPublisher<MileageCost, Error>
}
```

### 5.3 收據OCR用例
```swift
struct ProcessReceiptUseCase {
    let repository: ReceiptRepository
    let ocrService: OCRService
    
    func execute(receiptImage: UIImage) -> AnyPublisher<Expense?, Error>
}
```

### 5.4 儀表板用例
```swift
struct GetDashboardDataUseCase {
    let expenseRepository: ExpenseRepository
    let incomeRepository: IncomeRepository
    let mileageRepository: MileageRepository
    let workHoursRepository: WorkHoursRepository
    
    func execute(period: Period) -> AnyPublisher<DashboardData, Error>
}
```

## 6. 主要視圖模型(ViewModels)

### 6.1 儀表板ViewModel
```swift
class DashboardViewModel: ObservableObject {
    @Published var dashboardData: DashboardData?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var selectedPeriod: Period = .month
    
    private let getDashboardDataUseCase: GetDashboardDataUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(getDashboardDataUseCase: GetDashboardDataUseCase) {
        self.getDashboardDataUseCase = getDashboardDataUseCase
    }
    
    func loadDashboardData() {
        isLoading = true
        
        getDashboardDataUseCase.execute(period: selectedPeriod)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] data in
                    self?.dashboardData = data
                }
            )
            .store(in: &cancellables)
    }
    
    func changePeriod(to period: Period) {
        selectedPeriod = period
        loadDashboardData()
    }
}
```

### 6.2 支出列表ViewModel
```swift
class ExpenseListViewModel: ObservableObject {
    @Published var expenses: [ExpenseItemViewModel] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var filterCategory: String?
    
    private let getExpensesUseCase: GetExpensesUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(getExpensesUseCase: GetExpensesUseCase) {
        self.getExpensesUseCase = getExpensesUseCase
    }
    
    func loadExpenses() {
        isLoading = true
        
        getExpensesUseCase.execute()
            .receive(on: RunLoop.main)
            .map { expenses in
                expenses.map { ExpenseItemViewModel(expense: $0) }
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] expenses in
                    self?.expenses = expenses
                    self?.applyFilter()
                }
            )
            .store(in: &cancellables)
    }
    
    func applyFilter() {
        guard let category = filterCategory else { return }
        // Apply filter logic
    }
}
```

### 6.3 支出表單ViewModel
```swift
class ExpenseFormViewModel: ObservableObject {
    @Published var date: Date = Date()
    @Published var amount: String = ""
    @Published var category: String = "Fuel"
    @Published var description: String = ""
    @Published var isTaxDeductible: Bool = true
    @Published var taxDeductiblePercentage: Int = 100
    @Published var isProcessing: Bool = false
    @Published var error: Error?
    @Published var receiptImage: UIImage?
    @Published var shouldUseOCR: Bool = false
    
    private let saveExpenseUseCase: SaveExpenseUseCase
    private let processReceiptUseCase: ProcessReceiptUseCase
    private var cancellables = Set<AnyCancellable>()
    
    var expense: Expense?
    var isEditMode: Bool { expense != nil }
    
    init(saveExpenseUseCase: SaveExpenseUseCase, processReceiptUseCase: ProcessReceiptUseCase) {
        self.saveExpenseUseCase = saveExpenseUseCase
        self.processReceiptUseCase = processReceiptUseCase
    }
    
    func saveExpense() {
        isProcessing = true
        
        // Create expense from form data
        let newExpense = expense ?? Expense()
        // Set properties
        
        saveExpenseUseCase.execute(expense: newExpense)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isProcessing = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { _ in
                    // Handle success
                }
            )
            .store(in: &cancellables)
    }
    
    func processReceiptWithOCR() {
        guard let image = receiptImage else { return }
        isProcessing = true
        
        processReceiptUseCase.execute(receiptImage: image)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isProcessing = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] expense in
                    guard let expense = expense else { return }
                    // Update form with OCR results
                    self?.updateFormWithExpense(expense)
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateFormWithExpense(_ expense: Expense) {
        // Update form fields
    }
}
```

## 7. SwiftUI視圖結構

### 7.1 主要導航結構
```swift
struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            DashboardView()
                .tabItem {
                    Label("儀表板", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            ExpensesView()
                .tabItem {
                    Label("支出", systemImage: "creditcard.fill")
                }
                .tag(1)
            
            MileageView()
                .tabItem {
                    Label("里程", systemImage: "car.fill")
                }
                .tag(2)
            
            WorkHoursView()
                .tabItem {
                    Label("工時", systemImage: "clock.fill")
                }
                .tag(3)
            
            MoreView()
                .tabItem {
                    Label("更多", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
    }
}
```

### 7.2 儀表板視圖
```swift
struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel = // 注入
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 期間選擇器
                    Picker("期間", selection: $viewModel.selectedPeriod) {
                        Text("本週").tag(Period.week)
                        Text("本月").tag(Period.month)
                        Text("本季").tag(Period.quarter)
                        Text("本年").tag(Period.year)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // 收入支出摘要卡片
                    SummaryCardView(data: viewModel.dashboardData?.summary)
                    
                    // 時薪卡片
                    MetricCardView(
                        title: "平均時薪",
                        value: viewModel.dashboardData?.averageHourlyRate.formatted(.currency(code: "GBP")) ?? "-",
                        icon: "sterling", 
                        color: .blue
                    )
                    
                    // 每英里成本卡片
                    MetricCardView(
                        title: "每英里成本",
                        value: viewModel.dashboardData?.costPerMile.formatted(.currency(code: "GBP")) ?? "-",
                        icon: "car", 
                        color: .orange
                    )
                    
                    // 圖表
                    ChartView(data: viewModel.dashboardData?.chartData)
                    
                    // 稅務摘要
                    TaxSummaryView(data: viewModel.dashboardData?.taxSummary)
                }
                .padding()
            }
            .navigationTitle("儀表板")
            .onAppear {
                viewModel.loadDashboardData()
            }
            .refreshable {
                viewModel.loadDashboardData()
            }
        }
    }
}
```

## 8. Firebase集成

### 8.1 初始化

```swift
// AppDelegate.swift
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
}

// DriveNoteApp.swift
@main
struct DriveNoteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 8.2 Firebase Repository實現

```swift
class FirebaseExpenseRepository: ExpenseRepository {
    private let db = Firestore.firestore()
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func getAllExpenses() -> AnyPublisher<[Expense], Error> {
        guard let userId = authService.getCurrentUserId() else {
            return Fail(error: NSError(domain: "Not logged in", code: 401))
                .eraseToAnyPublisher()
        }
        
        return Future<[Expense], Error> { promise in
            self.db.collection("users/\(userId)/expenses")
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let expenses = documents.compactMap { doc -> Expense? in
                        try? doc.data(as: Expense.self)
                    }
                    
                    promise(.success(expenses))
                }
        }
        .eraseToAnyPublisher()
    }
    
    // 其他方法實現...
}
```

## 9. Gemini OCR集成

### 9.1 OCR服務實現

```swift
class GeminiOCRService: OCRService {
    private let functions = Functions.functions()
    
    func analyzeReceiptImage(imageData: Data) -> AnyPublisher<OCRResult, Error> {
        return Future<OCRResult, Error> { promise in
            // Convert image data to base64
            let base64Image = imageData.base64EncodedString()
            
            // Call Firebase Function that interfaces with Gemini API
            self.functions.httpsCallable("analyzeReceipt").call(["image": base64Image]) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let data = result?.data as? [String: Any] else {
                    promise(.failure(NSError(domain: "Invalid result format", code: 400)))
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let ocrResult = try JSONDecoder().decode(OCRResult.self, from: jsonData)
                    promise(.success(ocrResult))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
```

### 9.2 Firebase Function (Node.js)

```javascript
// Firebase Function (分離文件)
const functions = require('firebase-functions');
const { GoogleGenerativeAI } = require('@google/generative-ai');

exports.analyzeReceipt = functions.https.onCall(async (data, context) => {
  // 確認請求格式
  if (!data.image) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing image data');
  }
  
  try {
    // 初始化Gemini API
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-experimental" });
    
    // 準備圖片資料
    const imageBase64 = data.image;
    
    // 呼叫Gemini API
    const result = await model.generateContent({
      contents: [
        {
          role: "user",
          parts: [
            {
              text: "Analyze this receipt image. Extract the following information in JSON format: vendor name, date, total amount, tax amount (if present), category of expense (Fuel, Insurance, Maintenance, Vehicle Tax, or Other), and line items if available. Do not include any other commentary.",
            },
            {
              inlineData: {
                mimeType: "image/jpeg",
                data: imageBase64
              }
            }
          ]
        }
      ]
    });
    
    const response = result.response;
    const textContent = response.text();
    
    // 解析JSON回應
    const jsonMatch = textContent.match(/```json\n([\s\S]*?)\n```/) || 
                      textContent.match(/{[\s\S]*}/);
                      
    let parsedData;
    if (jsonMatch) {
      const jsonString = jsonMatch[1] || jsonMatch[0];
      parsedData = JSON.parse(jsonString);
    } else {
      throw new Error("Could not extract JSON from Gemini response");
    }
    
    return parsedData;
    
  } catch (error) {
    console.error("Error analyzing receipt:", error);
    throw new functions.https.HttpsError('internal', 'Error analyzing receipt', error);
  }
});
```

## 10. 依賴注入

### 10.1 依賴注入容器

```swift
class DIContainer {
    static let shared = DIContainer()
    
    // Services
    lazy var authService: AuthService = FirebaseAuthService()
    lazy var ocrService: OCRService = GeminiOCRService()
    lazy var syncService: SyncService = FirebaseSyncService(
        authService: authService
    )
    
    // Repositories
    lazy var expenseRepository: ExpenseRepository = {
        let coreDataRepo = CoreDataExpenseRepository()
        let firebaseRepo = FirebaseExpenseRepository(authService: authService)
        
        return ExpenseRepositoryImpl(
            localDataSource: coreDataRepo,
            remoteDataSource: firebaseRepo
        )
    }()
    
    // 其他存儲庫...
    
    // Use Cases
    lazy var saveExpenseUseCase = SaveExpenseUseCase(repository: expenseRepository)
    lazy var getExpensesUseCase = GetExpensesUseCase(repository: expenseRepository)
    // 其他用例...
    
    // ViewModels
    func makeDashboardViewModel() -> DashboardViewModel {
        return DashboardViewModel(
            getDashboardDataUseCase: GetDashboardDataUseCase(
                expenseRepository: expenseRepository,
                incomeRepository: incomeRepository,
                mileageRepository: mileageRepository,
                workHoursRepository: workHoursRepository
            )
        )
    }
    
    // 其他ViewModel工廠方法...
}
```

### 10.2 在SwiftUI中使用

```swift
struct DashboardView: View {
    @StateObject private var viewModel = DIContainer.shared.makeDashboardViewModel()
    
    var body: some View {
        // 視圖內容...
    }
}
```

## 11. 編碼規範

### 11.1 命名規範

- **類型**：使用駝峰式命名法，首字母大寫 (ExpenseRepository)
- **變量和函數**：使用駝峰式命名法，首字母小寫 (saveExpense)
- **常量**：全部大寫，用下劃線分隔 (MAX_UPLOAD_SIZE)
- **枚舉成員**：使用駝峰式命名法，首字母小寫 (expenseCategory.fuel)

### 11.2 文件結構

每個Swift文件應包含：
1. 版權聲明 (如適用)
2. 導入語句
3. 協議聲明
4. 類/結構體實現
5. 擴展

### 11.3 注釋

- 使用標準的Swift文檔注釋格式
- 所有公開API必須添加文檔注釋
- 複雜的私有方法和算法應當有解釋性注釋

```swift
/// 將收據圖片進行OCR分析並創建支出記錄
/// - Parameters:
///   - imageData: 收據圖片的二進制數據
/// - Returns: 一個結果發布者，成功時包含解析後的支出對象，失敗時包含錯誤
func analyzeReceiptImage(imageData: Data) -> AnyPublisher<Expense, Error> {
    // Implementation
}
```

### 11.4 錯誤處理

- 使用自定義錯誤類型，明確錯誤來源和類型
- 在適當的地方使用可選值和結果類型
- 不要在生產代碼中使用強制解包 (!)

```swift
enum NetworkError: Error {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingError
    case noInternetConnection
}
```

## 12. 測試策略

### 12.1 單元測試

- 為Domain層的每個用例編寫測試
- 為Repository接口實現編寫測試
- 使用模擬對象隔離依賴

```swift
func testGetExpensesUseCase() {
    // Setup
    let mockRepository = MockExpenseRepository()
    let useCase = GetExpensesUseCase(repository: mockRepository)
    
    // Expectation
    let expectation = XCTestExpectation(description: "Fetch expenses")
    
    // Mock data
    let mockExpenses = [Expense.mock(), Expense.mock()]
    mockRepository.mockExpenses = mockExpenses
    
    // Execute
    var receivedExpenses: [Expense] = []
    
    useCase.execute()
        .sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Should not fail")
                }
                expectation.fulfill()
            },
            receiveValue: { expenses in
                receivedExpenses = expenses
            }
        )
        .store(in: &cancellables)
    
    // Assert
    wait(for: [expectation], timeout: 1.0)
    XCTAssertEqual(receivedExpenses.count, mockExpenses.count)
}
```

### 12.2 UI測試

- 使用XCUITest為關鍵用戶流程編寫測試
- 關注於關鍵業務流程，如添加支出、生成報告等

## 13. 部署流程

### 13.1 開發環境設置

1. 安裝Xcode 14.3
2. 克隆Git儲存庫
3. 運行`pod install`安裝依賴
4. 復制Firebase配置文件
5. 設置Gemini API金鑰

### 13.2 App Store發布清單

1. 創建App Store Connect應用
2. 準備app屏幕截圖 (各設備尺寸)
3. 應用描述和關鍵詞
4. 隱私政策
5. 應用分類: 財務 > 稅務

## 14. 性能考量

### 14.1 針對Xcode 14.3和2017 MacBook Pro的建議

1. **減少編譯時間**:
   - 使用模塊化設計，減少整個項目的重新編譯
   - 優先使用Swift標準庫中的類型和函數
   - 避免過度使用泛型和協議抽象

2. **減少內存使用**:
   - 實現分頁加載，避免一次性加載大量數據
   - 優化圖像處理，使用適當的圖像壓縮
   - 清理不再使用的資源

3. **優化項目設置**:
   - 禁用非必要的構建設置
   - 使用增量構建
   - 將模擬器設置為低性能設備 (iPhone SE)以提高模擬器性能

### 14.2 離線優先策略

1. **優先使用本地存儲**:
   - 所有操作首先寫入Core Data
   - 當有網絡連接時才同步到Firebase
   - 實現衝突解決策略，通常以最新修改為準

2. **後台同步**:
   - 使用后台任務進行數據同步
   - 在應用進入後台時和啟動時嘗試同步
   - 使用指數退避算法處理同步失敗