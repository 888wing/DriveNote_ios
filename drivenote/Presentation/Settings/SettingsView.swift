import SwiftUI
import CoreData

struct SettingsView: View {
    @State private var isSyncEnabled = false
    @State private var showDebugInfo = false
    @State private var showAboutSheet = false
    @State private var currency = "GBP"
    @State private var distanceUnit = "miles"
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    let currencies = ["GBP", "EUR", "USD"]
    let distanceUnits = ["miles", "kilometers"]
    
    // App version info
    let appVersion = "1.0.0"
    let buildNumber = "1"
    
    // 用於診斷的方法
    private func testCoreDataConnection() {
        // 獲取 Core Data 上下文
        let context = CoreDataManager.shared.viewContext
        
        // 檢查所有主要實體
        var message = "數據庫連接測試結果:\n\n"
        let entityNames = ["CDExpense", "CDMileage", "CDWorkHours", "CDReceipt", "CDIncome"]
        
        for entityName in entityNames {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            request.fetchLimit = 10
            
            do {
                let results = try context.fetch(request)
                message += "✅ \(entityName): 可訪問，找到 \(results.count) 條記錄\n"
            } catch {
                message += "❌ \(entityName): 無法訪問: \(error.localizedDescription)\n"
            }
        }
        
        // 檢查是否可以創建測試對象
        let testEntity = NSEntityDescription.insertNewObject(forEntityName: "CDExpense", into: context)
        context.delete(testEntity) // 立即刪除測試對象
        message += "\n✅ 可以創建和刪除測試對象"
        
        alertTitle = "數據庫連接測試"
        alertMessage = message
        showAlert = true
    }
    
    private func insertTestData() {
        _ = CoreDataManager.shared.performBackgroundTask { context in
            let expense = NSEntityDescription.insertNewObject(forEntityName: "CDExpense", into: context) as! CDExpense
            expense.id = UUID()
            expense.date = Date()
            expense.amount = Double.random(in: 10...100)
            expense.category = ["fuel", "maintenance", "insurance", "other"].randomElement()!
            expense.descriptionText = "測試記錄 - \(Date().formatted())"
            expense.isTaxDeductible = true
            expense.taxDeductiblePercentage = 100
            expense.creationMethod = "manual"
            expense.isUploaded = false
            expense.lastModified = Date()
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    alertTitle = "測試數據"
                    alertMessage = "成功添加測試數據！"
                    showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    alertTitle = "添加測試數據失敗"
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
            
            return () // 返回空元組，滿足返回類型
        }
    }
    
    private func resetCoreDataStore() {
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
        
        for url in filesToDelete {
            if fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.removeItem(at: url)
                } catch {
                    alertTitle = "數據庫重置失敗"
                    alertMessage = "錯誤: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
            }
        }
        
        alertTitle = "數據庫已重置"
        alertMessage = "應用需要重新啟動以完成重置。請手動關閉並重新啟動應用程序。"
        showAlert = true
    }
    
    var body: some View {
        NavigationView {
            List {
                // App info section
                Section {
                    HStack {
                        VStack(alignment: .center) {
                            Image(systemName: "car.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.primaryBlue)
                            
                            Text("DriveNote")
                                .font(.title2)
                                .bold()
                            
                            Text("版本 \(appVersion) (\(buildNumber))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
                
                // Preferences
                Section(header: Text("偏好設置")) {
                    // Currency
                    Picker(selection: $currency, label: HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.primaryBlue)
                        Text("貨幣")
                    }) {
                        ForEach(currencies, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    // Distance unit
                    Picker(selection: $distanceUnit, label: HStack {
                        Image(systemName: "ruler")
                            .foregroundColor(.primaryBlue)
                        Text("距離單位")
                    }) {
                        ForEach(distanceUnits, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                // Cloud Sync - Placeholder for future development
                Section(header: Text("雲端同步")) {
                    Toggle(isOn: $isSyncEnabled) {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(.primaryBlue)
                            Text("啟用雲端同步")
                        }
                    }
                    .disabled(true) // Disabled for MVP
                    
                    if isSyncEnabled {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.primaryBlue)
                            Text("最後同步時間")
                            Spacer()
                            Text("從未")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.primaryBlue)
                        Text("雲端同步功能將在未來版本推出")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // About and Info
                Section(header: Text("關於")) {
                    Button(action: {
                        showAboutSheet = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.primaryBlue)
                            Text("關於DriveNote")
                        }
                    }
                    
                    // Privacy Policy - Would link to actual policy in production
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.primaryBlue)
                            Text("隱私政策")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                    
                    // Terms of Service - Would link to actual terms in production
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.primaryBlue)
                            Text("使用條款")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                }
                
                // Debug section (always visible in emergency mode)
                Section(header: Text("開發者選項")) {
                    Button(action: {
                        // 恢復到完整模式，顯示一個警告
                        alertTitle = "導航至其他頁面"
                        alertMessage = "您可以嘗試導航到其他頁面，但可能會因為數據庫問題而不穩定。建議先點擊「測試數據庫連接」確認可以正常連接。"
                        showAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                                .foregroundColor(.green)
                            Text("啟用所有頁面")
                        }
                    }
                    
                    // 直接顯示所有調試選項，不需要切換
                    HStack {
                        Text("設備ID")
                        Spacer()
                        Text("DEV-\(String(UUID().uuidString.prefix(8)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("構建類型")
                        Spacer()
                        Text("DEBUG")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    Button(action: {
                        testCoreDataConnection()
                    }) {
                        HStack {
                            Image(systemName: "database")
                                .foregroundColor(.primaryBlue)
                            Text("測試數據庫連接")
                        }
                    }
                    
                    Button(action: {
                        insertTestData()
                    }) {
                        HStack {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.primaryBlue)
                            Text("插入測試數據")
                        }
                    }
                    
                    Button(action: {
                        resetCoreDataStore()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("重置數據庫")
                        }
                    }
                    .foregroundColor(.red)
                }
                
                // App credits
                Section {
                    VStack(alignment: .center) {
                        Text("© 2025 DriveNote.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("為英國 Uber 司機開發")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("設置")
            .sheet(isPresented: $showAboutSheet) {
                AboutView()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("確定"))
                )
            }
        }
    }
}

// About sheet view
struct AboutView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Image(systemName: "car.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.primaryBlue)
                    
                    Text("DriveNote")
                        .font(.title)
                        .bold()
                    
                    Text("版本 1.0.0 (1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                VStack(spacing: 15) {
                    Text("為Uber司機設計的一站式管理工具")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("DriveNote幫助您追蹤收入、支出、里程和工時，簡化稅務申報流程，讓您專注於駕駛體驗。")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    VStack(spacing: 8) {
                        FeatureRow(icon: "dollarsign.square", text: "輕鬆追蹤收入與支出")
                        FeatureRow(icon: "car", text: "記錄里程，自動計算成本")
                        FeatureRow(icon: "clock", text: "工時記錄，了解實際時薪")
                        FeatureRow(icon: "percent", text: "識別可抵稅項目，節省稅費")
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Text("© 2025 DriveNote. 保留所有權利。")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .navigationBarTitle("關於", displayMode: .inline)
            .navigationBarItems(trailing: Button("關閉") {
                // This will be handled by the sheet dismissal
            })
        }
    }
}

// Feature row for AboutView
struct FeatureRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.primaryBlue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
