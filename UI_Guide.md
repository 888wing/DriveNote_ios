# DriveNote iOS - 時尚現代UI設計指南

## 1. 設計願景

DriveNote iOS應用旨在打造一個專業、清晰且現代的用戶界面，幫助Uber司機輕鬆管理收支並準備稅務。我們的設計理念核心是：**簡約但不簡單、實用但有品味、專業但不呆板**。

## 2. 色彩系統

### 2.1 主色調

推薦使用深色主題與鮮明強調色的組合，賦予應用現代感和專業氛圍。

```swift
// 色彩定義
extension Color {
    static let primaryBackground = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    
    // 主色調 - 深藍色，穩重專業
    static let primaryBlue = Color(hex: "0A84FF")
    static let deepBlue = Color(hex: "0050C5")
    
    // 強調色 - 清新綠色，象徵收入/利潤
    static let accentGreen = Color(hex: "30D158")
    static let deepGreen = Color(hex: "248A3D")
    
    // 警示色 - 支出用橙色
    static let expenseOrange = Color(hex: "FF9500")
    static let deepOrange = Color(hex: "C93400")
    
    // 中性色調
    static let neutralGray = Color(hex: "8E8E93")
    static let lightGray = Color(hex: "E5E5EA")
}
```

### 2.2 色彩語義

建立一套語義色彩系統，使用戶能直觀理解界面:

- **藍色系**: 用於主要操作、導航和品牌識別
- **綠色系**: 用於收入、盈利和積極數據
- **橙色系**: 用於支出、費用和警示
- **灰色系**: 用於中性元素、背景和分隔

### 2.3 深色模式

完整支持深色模式，自動適應系統設置:

```swift
// 自適應色彩
static let cardBackground = Color(UIColor { traitCollection in
    return traitCollection.userInterfaceStyle == .dark ? 
        UIColor(hex: "1C1C1E") : UIColor(hex: "FFFFFF")
})

static let textPrimary = Color(UIColor { traitCollection in
    return traitCollection.userInterfaceStyle == .dark ? 
        UIColor(hex: "FFFFFF") : UIColor(hex: "000000")
})
```

## 3. 排版系統

### 3.1 字體選擇

使用Apple的SF Pro字體系統，但通過不同權重和大小創建清晰的視覺層次:

```swift
// 創建類型比例
extension Font {
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let titleLarge = Font.system(size: 22, weight: .bold)
    static let titleMedium = Font.system(size: 17, weight: .semibold)
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 13, weight: .medium)
    static let overline = Font.system(size: 12, weight: .semibold).smallCaps()
    
    // 數字顯示專用字體
    static let monoLarge = Font.system(size: 34, weight: .medium, design: .monospaced)
    static let monoMedium = Font.system(size: 22, weight: .medium, design: .monospaced)
}
```

### 3.2 文字間距

正確的文字間距能提升可讀性和視覺美感:

```swift
Text("儀表板")
    .font(.titleLarge)
    .tracking(0.5) // 標題略微增加字元間距
    .lineSpacing(1.2) // 增加行間距
```

## 4. 組件設計

### 4.1 卡片設計

採用現代卡片設計，使用微妙陰影和圓角:

```swift
struct ModernCard<Content: View>: View {
    var title: String
    var icon: String
    var tint: Color
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(tint)
                Text(title)
                    .font(.titleMedium)
                Spacer()
            }
            
            content()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
```

### 4.2 數據可視化

使用現代化圖表設計，確保清晰易讀:

```swift
struct ModernBarChart: View {
    var data: [DataPoint]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { point in
                    VStack {
                        ZStack(alignment: .bottom) {
                            // 背景柱
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.lightGray)
                                .frame(height: 150)
                            
                            // 數據柱
                            RoundedRectangle(cornerRadius: 8)
                                .fill(point.value > 0 ? Color.accentGreen : Color.expenseOrange)
                                .frame(height: CGFloat(abs(point.value)) * 150 / 100)
                        }
                        .frame(width: 24)
                        
                        Text(point.label)
                            .font(.caption)
                            .padding(.top, 4)
                    }
                }
            }
            .padding(.top, 16)
        }
    }
}
```

### 4.3 表單設計

現代化表單控件，注重觸感和視覺反饋:

```swift
struct ModernTextField: View {
    var label: String
    var icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                TextField("", text: $text)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.lightGray, lineWidth: 1)
            )
        }
        .padding(.bottom, 8)
    }
}
```

### 4.4 按鈕設計

採用漸變色彩和細微動畫的按鈕:

```swift
struct GradientButton: View {
    var title: String
    var icon: String?
    var gradient: LinearGradient
    var action: () -> Void
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
        
        self.gradient = LinearGradient(
            gradient: Gradient(colors: [.primaryBlue, .deepBlue]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                        .padding(.trailing, 4)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(gradient)
            .cornerRadius(14)
            .shadow(color: Color.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle()) // 添加縮放動畫
    }
}

// 按鈕動畫效果
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
```

## 5. 導航與佈局

### 5.1 Tab Bar 設計

採用現代化自定義Tab Bar:

```swift
struct ModernTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: getIcon(index))
                                .font(.system(size: 22))
                                .foregroundColor(selectedTab == index ? .primaryBlue : .gray)
                            
                            Text(getTitle(index))
                                .font(.caption2)
                                .fontWeight(selectedTab == index ? .semibold : .regular)
                                .foregroundColor(selectedTab == index ? .primaryBlue : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedTab == index ?
                                Color.primaryBlue.opacity(0.1) :
                                Color.clear
                        )
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 5)
            .padding(.horizontal)
        }
    }
    
    func getIcon(_ index: Int) -> String {
        switch index {
        case 0: return "chart.bar.fill"
        case 1: return "creditcard.fill"
        case 2: return "car.fill"
        case 3: return "clock.fill"
        case 4: return "ellipsis.circle.fill"
        default: return ""
        }
    }
    
    func getTitle(_ index: Int) -> String {
        switch index {
        case 0: return "儀表板"
        case 1: return "支出"
        case 2: return "里程"
        case 3: return "工時"
        case 4: return "更多"
        default: return ""
        }
    }
}
```

### 5.2 流暢佈局

使用間距和比例的現代佈局:

```swift
// 預設間距
struct Spacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let huge: CGFloat = 32
}

// 使用一致的間距
VStack(spacing: Spacing.medium) {
    // 內容
}
.padding(.horizontal, Spacing.large)
.padding(.vertical, Spacing.medium)
```

## 6. 動畫與交互

### 6.1 微互動

添加細微動畫提升使用體驗:

```swift
// 視圖出現時的動畫
.onAppear {
    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
        opacity = 1
        offset = 0
    }
}

// 滑動手勢
.gesture(
    DragGesture(minimumDistance: 10)
        .onEnded { gesture in
            if gesture.translation.width < -50 {
                // 向左滑動操作
            } else if gesture.translation.width > 50 {
                // 向右滑動操作
            }
        }
)
```

### 6.2 過渡效果

使用自然過渡效果:

```swift
// 頁面轉場效果
.transition(
    .asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
)
```

## 7. 具體UI示例

### 7.1 儀表板設計

```swift
struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // 頂部收支概覽卡
                SummaryCardView(data: viewModel.summaryData)
                
                // 時薪與里程成本指標
                HStack(spacing: Spacing.medium) {
                    MetricCardView(
                        title: "平均時薪",
                        value: viewModel.hourlyRate.formatted(.currency(code: "GBP")),
                        icon: "sterling.sign.circle.fill",
                        color: .accentGreen
                    )
                    
                    MetricCardView(
                        title: "每英里成本",
                        value: viewModel.costPerMile.formatted(.currency(code: "GBP")),
                        icon: "fuelpump.fill",
                        color: .expenseOrange
                    )
                }
                
                // 收支圖表
                ChartCardView(data: viewModel.chartData)
                
                // 稅務摘要
                TaxSummaryView(data: viewModel.taxData)
            }
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.large)
        }
        .navigationTitle("儀表板")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            viewModel.refresh()
        }
    }
}

// 收支摘要卡片設計
struct SummaryCardView: View {
    var data: SummaryData
    
    var body: some View {
        VStack(spacing: Spacing.medium) {
            // 總體收支狀況
            HStack {
                VStack(alignment: .leading) {
                    Text("本月總收入")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(data.income.formatted(.currency(code: "GBP")))
                        .font(.monoLarge)
                        .foregroundColor(.accentGreen)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("本月總支出")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(data.expense.formatted(.currency(code: "GBP")))
                        .font(.monoLarge)
                        .foregroundColor(.expenseOrange)
                }
            }
            
            Divider()
            
            // 收支差額
            VStack(alignment: .leading, spacing: 4) {
                Text("凈收入")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .lastTextBaseline) {
                    Text(data.netIncome.formatted(.currency(code: "GBP")))
                        .font(.monoLarge)
                        .foregroundColor(data.netIncome >= 0 ? .accentGreen : .red)
                    
                    if data.percentChange != nil {
                        Text("\(data.percentChange! >= 0 ? "+" : "")\(data.percentChange!.formatted(.percent))")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(data.percentChange! >= 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(data.percentChange! >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.large)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 10)
    }
}
```

### 7.2 支出記錄表單設計

```swift
struct ExpenseFormView: View {
    @ObservedObject var viewModel: ExpenseFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var formStep = 1
    
    var body: some View {
        VStack(spacing: 0) {
            // 頂部進度指示器
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景條
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.lightGray)
                        .frame(height: 4)
                    
                    // 進度條
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primaryBlue)
                        .frame(width: CGFloat(formStep) / 3 * geometry.size.width, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.large)
            
            // 表單內容容器
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.large) {
                    // 步驟標題
                    Text(getStepTitle(formStep))
                        .font(.titleLarge)
                        .padding(.horizontal, Spacing.large)
                    
                    // 表單步驟內容
                    if formStep == 1 {
                        basicInfoForm
                    } else if formStep == 2 {
                        detailsForm
                    } else {
                        taxInfoForm
                    }
                }
                .padding(.bottom, 100) // 為底部按鈕留出空間
            }
            
            // 底部導航按鈕
            bottomNavigationButtons
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.isEditMode ? "編輯支出" : "添加支出")
                    .font(.headline)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isEditMode {
                    Button(action: viewModel.deleteExpense) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    // 基本信息表單
    private var basicInfoForm: some View {
        VStack(spacing: Spacing.large) {
            // 類別選擇器
            VStack(alignment: .leading, spacing: 8) {
                Text("支出類別")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.medium) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                title: category.displayName,
                                icon: category.icon,
                                isSelected: viewModel.category == category,
                                action: {
                                    viewModel.category = category
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                }
            }
            
            // 日期選擇器
            DatePickerField(
                label: "日期",
                date: $viewModel.date,
                icon: "calendar"
            )
            
            // 金額輸入
            CurrencyInputField(
                label: "金額",
                value: $viewModel.amount,
                icon: "sterling.sign"
            )
        }
        .padding(.horizontal, Spacing.large)
    }
    
    // 詳細信息表單
    private var detailsForm: some View {
        VStack(spacing: Spacing.large) {
            // 描述輸入
            ModernTextField(
                label: "描述",
                icon: "text.alignleft",
                text: $viewModel.description
            )
            
            // 收據上傳
            ReceiptUploadField(
                receiptImage: $viewModel.receiptImage,
                isProcessingImage: $viewModel.isProcessingReceipt
            )
            
            // 自定義字段 (基於類別)
            if viewModel.category == .fuel {
                fuelDetailsView
            } else if viewModel.category == .maintenance {
                maintenanceDetailsView
            }
        }
        .padding(.horizontal, Spacing.large)
    }
    
    // 稅務信息表單
    private var taxInfoForm: some View {
        VStack(spacing: Spacing.large) {
            // 稅務減免開關
            VStack(alignment: .leading, spacing: 8) {
                Text("稅務信息")
                    .font(.titleMedium)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("此支出可抵稅")
                            .font(.bodyMedium)
                        
                        if viewModel.isTaxDeductible {
                            Text("此支出將計入年度稅務報表")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $viewModel.isTaxDeductible)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .accentGreen))
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
            }
            
            // 減免比例選擇器 (當可抵稅時)
            if viewModel.isTaxDeductible {
                VStack(alignment: .leading, spacing: 8) {
                    Text("可抵稅比例")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(viewModel.taxDeductiblePercentage)%")
                                .font(.headline)
                                .monospacedDigit()
                            
                            Spacer()
                            
                            if viewModel.taxDeductiblePercentage < 100 {
                                Text("部分商業用途")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("完全商業用途")
                                    .font(.caption)
                                    .foregroundColor(.accentGreen)
                            }
                        }
                        .padding(.bottom, 8)
                        
                        Slider(
                            value: Binding(
                                get: { Double(viewModel.taxDeductiblePercentage) },
                                set: { viewModel.taxDeductiblePercentage = Int($0) }
                            ),
                            in: 0...100,
                            step: 5
                        )
                        .accentColor(.accentGreen)
                    }
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(12)
                }
            }
            
            // 稅務提示
            if let taxTip = viewModel.getTaxTipForCategory() {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.primaryBlue)
                    
                    Text(taxTip)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding()
                .background(Color.primaryBlue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, Spacing.large)
    }
    
    // 底部導航按鈕
    private var bottomNavigationButtons: some View {
        VStack {
            Divider()
            
            HStack {
                // 上一步按鈕
                if formStep > 1 {
                    Button(action: {
                        withAnimation {
                            formStep -= 1
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("上一步")
                        }
                        .padding()
                        .foregroundColor(.primary)
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
                
                // 下一步/保存按鈕
                if formStep < 3 {
                    Button(action: {
                        withAnimation {
                            formStep += 1
                        }
                    }) {
                        HStack {
                            Text("下一步")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .buttonStyle(GradientButtonStyle())
                } else {
                    Button(action: {
                        viewModel.saveExpense {
                            dismiss()
                        }
                    }) {
                        HStack {
                            Text(viewModel.isEditMode ? "保存修改" : "添加支出")
                            Image(systemName: "checkmark")
                        }
                    }
                    .buttonStyle(GradientButtonStyle())
                    .disabled(viewModel.isProcessing)
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.medium)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: -5)
            )
        }
    }
    
    // 輔助方法
    private func getStepTitle(_ step: Int) -> String {
        switch step {
        case 1: return "基本信息"
        case 2: return "詳細資料"
        case 3: return "稅務信息"
        default: return ""
        }
    }
}

// 類別按鈕
struct CategoryButton: View {
    var title: String
    var icon: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.primaryBlue : Color(.tertiarySystemBackground))
                    .cornerRadius(15)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primaryBlue : .primary)
            }
        }
    }
}
```

## 8. 設計資源與參考

### 8.1 設計靈感來源

- **Apple Human Interface Guidelines** - 確保符合iOS設計準則
- **Stripe Dashboard App** - 優雅的財務資料呈現方式
- **Monzo Banking App** - 清晰的收支分類與視覺化
- **Notion** - 簡約現代的卡片與導航設計
- **Revolut** - 精美的圖表和資料視覺化

### 8.2 圖標與視覺資源

- 使用iOS內建的SF Symbols圖標庫
- 為主要功能選擇鮮明的標誌性圖標
- 確保圖標具有統一風格與一致性

### 8.3 設計系統建議

- 建立可重用的UI組件庫
- 使用自定義SwiftUI修飾器保持設計一致性
- 為不同屏幕尺寸優化布局

## 9. 響應式設計考量

### 9.1 設備適配

確保UI在不同iPhone尺寸上均表現良好:

```swift
// 根據屏幕尺寸調整字體大小
@ScaledMetric(relativeTo: .headline) var headlineSize: CGFloat = 17

// 使用動態尺寸
.font(.system(size: headlineSize, weight: .semibold))
```

### 9.2 橫豎屏適配

適應不同的屏幕方向:

```swift
// 響應方向變化
@Environment(\.horizontalSizeClass) var horizontalSizeClass
@Environment(\.verticalSizeClass) var verticalSizeClass

var body: some View {
    if horizontalSizeClass == .compact && verticalSizeClass == .regular {
        // iPhone豎屏布局
        verticalLayout
    } else {
        // iPad或iPhone橫屏布局
        horizontalLayout
    }
}
```

## 10. 可訪問性考量

### 10.1 動態字體支持

```swift
// 支持動態類型
.font(.headline)
.dynamicTypeSize(.large...(.accessibility3))
```

### 10.2 顏色對比度

確保文本與背景之間有足夠的對比度:

```swift
// 高對比度文本
Text("重要信息")
    .foregroundColor(.primary)
    .padding()
    .background(Color(.systemBackground))
```

### 10.3 VoiceOver支持

添加適當的無障礙標籤:

```swift
// 無障礙標籤
.accessibilityLabel("每日收入趨勢圖表")
.accessibilityValue("本週平均每日收入£120")
```