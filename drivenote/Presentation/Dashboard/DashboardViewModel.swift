import Foundation
import Combine

class DashboardViewModel: StatefulViewModel<DashboardData> {
    // 儀表板指標
    @Published var totalIncome: Double = 0
    @Published var totalExpense: Double = 0
    @Published var netIncome: Double = 0
    @Published var hourlyRate: Double = 0
    @Published var costPerMile: Double = 0
    @Published var totalWorkHours: Double = 0
    @Published var totalMileage: Double = 0
    @Published var totalTaxDeductible: Double = 0
    
    // 圖表數據
    @Published var chartLabels: [String] = []
    @Published var incomeData: [Double] = []
    @Published var expenseData: [Double] = []
    
    // 變化百分比
    @Published var incomeChangePercent: Double?
    @Published var expenseChangePercent: Double?
    @Published var netIncomeChangePercent: Double?
    
    // 用戶選擇
    @Published var selectedPeriod: Period = .month
    
    // 依賴
    private let getDashboardDataUseCase: GetDashboardDataUseCase
    
    init(getDashboardDataUseCase: GetDashboardDataUseCase) {
        self.getDashboardDataUseCase = getDashboardDataUseCase
        super.init()
    }
    
    func loadDashboardData() {
        print("DashboardViewModel: 開始加載數據，期間: \(selectedPeriod.displayName)")
        setLoading()
        
        // 設置超時計時器
        let timeoutSeconds = 10.0
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeoutSeconds, repeats: false) { [weak self] _ in
            guard let self = self, case .loading = self.state else { return }
            
            print("DashboardViewModel: 加載超時")
            self.setError(NSError(
                domain: "com.drivenote", 
                code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "加載超時，請重試"]
            ))
        }
        
        getDashboardDataUseCase.execute(period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    timeoutTimer.invalidate() // 取消超時計時器
                    
                    if case .failure(let error) = completion {
                        print("DashboardViewModel: 加載失敗 - \(error.localizedDescription)")
                        self?.setError(error)
                    } else {
                        print("DashboardViewModel: 加載完成")
                    }
                },
                receiveValue: { [weak self] data in
                    timeoutTimer.invalidate() // 取消超時計時器
                    
                    if let self = self {
                        print("DashboardViewModel: 收到數據 - 總收入: \(data.summary.totalIncome), 總支出: \(data.summary.totalExpense)")
                        
                        // 檢查是否有數據
                        if data.isEmpty {
                            self.setEmpty()
                        } else {
                            self.updateDashboardData(data)
                            self.setLoaded(data)
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateDashboardData(_ data: DashboardData) {
        // 更新指標
        totalIncome = data.summary.totalIncome
        totalExpense = data.summary.totalExpense
        netIncome = data.summary.netIncome
        hourlyRate = data.metrics.hourlyRate
        costPerMile = data.metrics.costPerMile
        totalWorkHours = data.metrics.totalWorkHours
        totalMileage = data.metrics.totalMileage
        totalTaxDeductible = data.metrics.totalTaxDeductible
        
        // 更新圖表數據
        chartLabels = data.chartData.labels
        incomeData = data.chartData.incomeData
        expenseData = data.chartData.expenseData
        
        // 更新變化百分比
        incomeChangePercent = data.summary.incomeChangePercent
        expenseChangePercent = data.summary.expenseChangePercent
        netIncomeChangePercent = data.summary.netIncomeChangePercent
    }
    
    func changePeriod(to period: Period) {
        selectedPeriod = period
        loadDashboardData()
    }
    
    // 格式化字符串
    var formattedTotalIncome: String {
        return formatCurrency(totalIncome)
    }
    
    var formattedTotalExpense: String {
        return formatCurrency(totalExpense)
    }
    
    var formattedNetIncome: String {
        return formatCurrency(netIncome)
    }
    
    var formattedHourlyRate: String {
        return formatCurrency(hourlyRate)
    }
    
    var formattedCostPerMile: String {
        return formatCurrency(costPerMile)
    }
    
    var formattedTotalWorkHours: String {
        let hours = Int(totalWorkHours)
        let minutes = Int((totalWorkHours - Double(hours)) * 60)
        return "\(hours)時\(minutes)分"
    }
    
    var formattedTotalMileage: String {
        return String(format: "%.1f 英里", totalMileage)
    }
    
    var formattedTotalTaxDeductible: String {
        return formatCurrency(totalTaxDeductible)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "£"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "£0.00"
    }
    
    // MARK: - 錯誤處理
    
    override func canRecoverFromError(_ error: Error) -> Bool {
        // 某些網絡錯誤可以通過重試恢復
        if let nsError = error as NSError? {
            return nsError.domain == NSURLErrorDomain &&
                   (nsError.code == NSURLErrorNetworkConnectionLost ||
                    nsError.code == NSURLErrorNotConnectedToInternet ||
                    nsError.code == NSURLErrorTimedOut)
        }
        return false
    }
    
    override func attemptRecovery(from error: Error) {
        // 自動重試一次
        print("嘗試恢復並重新加載儀表板數據...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.loadDashboardData()
        }
    }
}

extension DashboardData {
    var isEmpty: Bool {
        return summary.totalIncome == 0 && summary.totalExpense == 0 && metrics.totalWorkHours == 0 && metrics.totalMileage == 0
    }
}
