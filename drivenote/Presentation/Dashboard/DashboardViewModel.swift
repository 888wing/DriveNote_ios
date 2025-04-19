import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    // Published properties for UI
    @Published var dashboardData: DashboardData?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var selectedPeriod: Period = .month
    
    // Metrics for display
    @Published var totalIncome: Double = 0
    @Published var totalExpense: Double = 0
    @Published var netIncome: Double = 0
    @Published var hourlyRate: Double = 0
    @Published var costPerMile: Double = 0
    @Published var totalWorkHours: Double = 0
    @Published var totalMileage: Double = 0
    @Published var totalTaxDeductible: Double = 0
    
    // Chart data
    @Published var chartLabels: [String] = []
    @Published var incomeData: [Double] = []
    @Published var expenseData: [Double] = []
    
    // Change percentages
    @Published var incomeChangePercent: Double?
    @Published var expenseChangePercent: Double?
    @Published var netIncomeChangePercent: Double?
    
    // Dependencies
    private let getDashboardDataUseCase: GetDashboardDataUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(getDashboardDataUseCase: GetDashboardDataUseCase) {
        self.getDashboardDataUseCase = getDashboardDataUseCase
        
        // Load data when initialized
        loadDashboardData()
    }
    
    func loadDashboardData() {
        isLoading = true
        error = nil
        
        getDashboardDataUseCase.execute(period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] data in
                    self?.updateDashboardData(data)
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateDashboardData(_ data: DashboardData) {
        // Update main data
        dashboardData = data
        
        // Update metrics
        totalIncome = data.summary.totalIncome
        totalExpense = data.summary.totalExpense
        netIncome = data.summary.netIncome
        hourlyRate = data.metrics.hourlyRate
        costPerMile = data.metrics.costPerMile
        totalWorkHours = data.metrics.totalWorkHours
        totalMileage = data.metrics.totalMileage
        totalTaxDeductible = data.metrics.totalTaxDeductible
        
        // Update chart data
        chartLabels = data.chartData.labels
        incomeData = data.chartData.incomeData
        expenseData = data.chartData.expenseData
        
        // Update change percentages
        incomeChangePercent = data.summary.incomeChangePercent
        expenseChangePercent = data.summary.expenseChangePercent
        netIncomeChangePercent = data.summary.netIncomeChangePercent
    }
    
    func changePeriod(to period: Period) {
        selectedPeriod = period
        loadDashboardData()
    }
    
    // Formatted string getters for display
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
}
