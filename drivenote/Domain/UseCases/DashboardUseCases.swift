import Foundation
import Combine

// 獲取儀表板數據用例
struct GetDashboardDataUseCase {
    private let expenseRepository: ExpenseRepository
    private let incomeRepository: IncomeRepository
    private let mileageRepository: MileageRepository
    private let workHoursRepository: WorkHoursRepository
    
    init(
        expenseRepository: ExpenseRepository,
        incomeRepository: IncomeRepository,
        mileageRepository: MileageRepository,
        workHoursRepository: WorkHoursRepository
    ) {
        self.expenseRepository = expenseRepository
        self.incomeRepository = incomeRepository
        self.mileageRepository = mileageRepository
        self.workHoursRepository = workHoursRepository
    }
    
    func execute(period: Period) -> AnyPublisher<DashboardData, Error> {
        let dateRange = period.dateRange()
        let previousDateRange = getPreviousPeriodRange(period: period)
        
        // 當前期間數據查詢
        let currentExpensesPublisher = expenseRepository.getExpensesByDateRange(start: dateRange.start, end: dateRange.end)
        let currentIncomePublisher = incomeRepository.getIncomeByDateRange(start: dateRange.start, end: dateRange.end)
        let currentMileagePublisher = mileageRepository.getMileageByDateRange(start: dateRange.start, end: dateRange.end)
        let currentWorkHoursPublisher = workHoursRepository.getWorkHoursByDateRange(start: dateRange.start, end: dateRange.end)
        
        // 上一期間數據查詢 (用於計算變化百分比)
        let previousExpensesPublisher = expenseRepository.getExpensesByDateRange(start: previousDateRange.start, end: previousDateRange.end)
        let previousIncomePublisher = incomeRepository.getIncomeByDateRange(start: previousDateRange.start, end: previousDateRange.end)
        
        // 組合所有查詢結果
        return Publishers.CombineLatest6(
            currentExpensesPublisher,
            currentIncomePublisher,
            currentMileagePublisher,
            currentWorkHoursPublisher,
            previousExpensesPublisher,
            previousIncomePublisher
        )
        .map { currentExpenses, currentIncome, currentMileage, currentWorkHours, previousExpenses, previousIncome in
            // 計算當前期間總數據
            let totalExpense = currentExpenses.reduce(0) { $0 + $1.amount }
            let totalIncome = currentIncome.reduce(0) { $0 + $1.totalAmount() }
            let totalMileage = currentMileage.reduce(0) { $0 + $1.distance }
            let totalWorkHours = currentWorkHours.reduce(0) { $0 + $1.totalHours }
            
            // 計算上一期間總數據
            let previousTotalExpense = previousExpenses.reduce(0) { $0 + $1.amount }
            let previousTotalIncome = previousIncome.reduce(0) { $0 + $1.totalAmount() }
            
            // 計算變化百分比
            let incomeChangePercent = calculateChangePercent(current: totalIncome, previous: previousTotalIncome)
            let expenseChangePercent = calculateChangePercent(current: totalExpense, previous: previousTotalExpense)
            let netIncomeChangePercent = calculateChangePercent(
                current: totalIncome - totalExpense,
                previous: previousTotalIncome - previousTotalExpense
            )
            
            // 計算時薪
            let hourlyRate = totalWorkHours > 0 ? totalIncome / totalWorkHours : 0
            
            // 計算每英里成本 (僅考慮燃料支出)
            let fuelExpenses = currentExpenses.filter { $0.category == .fuel }
            let totalFuelCost = fuelExpenses.reduce(0) { $0 + $1.amount }
            let costPerMile = totalMileage > 0 ? totalFuelCost / totalMileage : 0
            
            // 構建圖表數據
            let (chartLabels, incomeData, expenseData) = buildChartData(
                period: period,
                expenses: currentExpenses,
                income: currentIncome
            )
            
            // 可抵稅支出總額
            let totalTaxDeductible = currentExpenses.reduce(0) { $0 + $1.taxDeductibleAmount() }
            
            return DashboardData(
                period: period,
                summary: DashboardSummary(
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                    netIncome: totalIncome - totalExpense,
                    incomeChangePercent: incomeChangePercent,
                    expenseChangePercent: expenseChangePercent,
                    netIncomeChangePercent: netIncomeChangePercent
                ),
                metrics: DashboardMetrics(
                    hourlyRate: hourlyRate,
                    costPerMile: costPerMile,
                    totalMileage: totalMileage,
                    totalWorkHours: totalWorkHours,
                    totalTaxDeductible: totalTaxDeductible
                ),
                chartData: DashboardChartData(
                    labels: chartLabels,
                    incomeData: incomeData,
                    expenseData: expenseData
                )
            )
        }
        .eraseToAnyPublisher()
    }
    
    // 計算變化百分比
    private func calculateChangePercent(current: Double, previous: Double) -> Double? {
        guard previous != 0 else { return nil }
        return ((current - previous) / previous) * 100.0
    }
    
    // 獲取上一期間的日期範圍
    private func getPreviousPeriodRange(period: Period) -> (start: Date, end: Date) {
        let currentRange = period.dateRange()
        let calendar = Calendar.current
        
        switch period {
        case .day:
            let start = calendar.date(byAdding: .day, value: -1, to: currentRange.start)!
            let end = calendar.date(byAdding: .day, value: -1, to: currentRange.end)!
            return (start, end)
            
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: currentRange.start)!
            let end = calendar.date(byAdding: .day, value: -7, to: currentRange.end)!
            return (start, end)
            
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: currentRange.start)!
            let end = calendar.date(byAdding: .month, value: -1, to: currentRange.end)!
            return (start, end)
            
        case .quarter:
            let start = calendar.date(byAdding: .month, value: -3, to: currentRange.start)!
            let end = calendar.date(byAdding: .month, value: -3, to: currentRange.end)!
            return (start, end)
            
        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: currentRange.start)!
            let end = calendar.date(byAdding: .year, value: -1, to: currentRange.end)!
            return (start, end)
        }
    }
    
    // 構建圖表數據
    private func buildChartData(
        period: Period,
        expenses: [Expense],
        income: [Income]
    ) -> (labels: [String], incomeData: [Double], expenseData: [Double]) {
        let calendar = Calendar.current
        let dateRange = period.dateRange()
        
        switch period {
        case .day:
            // 按小時分組
            let hourLabels = (0...23).map { String(format: "%02d", $0) }
            
            var incomeByHour = [Double](repeating: 0, count: 24)
            var expenseByHour = [Double](repeating: 0, count: 24)
            
            for item in income {
                let hour = calendar.component(.hour, from: item.date)
                incomeByHour[hour] += item.totalAmount()
            }
            
            for item in expenses {
                let hour = calendar.component(.hour, from: item.date)
                expenseByHour[hour] += item.amount
            }
            
            return (hourLabels, incomeByHour, expenseByHour)
            
        case .week:
            // 按日分組
            let dayLabels = ["一", "二", "三", "四", "五", "六", "日"]
            
            var incomeByDay = [Double](repeating: 0, count: 7)
            var expenseByDay = [Double](repeating: 0, count: 7)
            
            for item in income {
                // 將週日作為1，週六作為7
                var weekday = calendar.component(.weekday, from: item.date) - 1
                if weekday == 0 { weekday = 7 } // 調整週日
                weekday = (weekday + 5) % 7 // 將週一作為0
                incomeByDay[weekday] += item.totalAmount()
            }
            
            for item in expenses {
                var weekday = calendar.component(.weekday, from: item.date) - 1
                if weekday == 0 { weekday = 7 }
                weekday = (weekday + 5) % 7
                expenseByDay[weekday] += item.amount
            }
            
            return (dayLabels, incomeByDay, expenseByDay)
            
        case .month:
            // 按週分組
            let weekCount = 5 // 假設一個月有5週
            let weekLabels = (1...weekCount).map { "第\($0)週" }
            
            var incomeByWeek = [Double](repeating: 0, count: weekCount)
            var expenseByWeek = [Double](repeating: 0, count: weekCount)
            
            let startOfMonth = dateRange.start
            
            for item in income {
                let dayDiff = calendar.dateComponents([.day], from: startOfMonth, to: item.date).day ?? 0
                let weekIndex = min(dayDiff / 7, weekCount - 1)
                incomeByWeek[weekIndex] += item.totalAmount()
            }
            
            for item in expenses {
                let dayDiff = calendar.dateComponents([.day], from: startOfMonth, to: item.date).day ?? 0
                let weekIndex = min(dayDiff / 7, weekCount - 1)
                expenseByWeek[weekIndex] += item.amount
            }
            
            return (weekLabels, incomeByWeek, expenseByWeek)
            
        case .quarter, .year:
            // 按月分組
            let monthCount = period == .quarter ? 3 : 12
            let monthLabels = (1...monthCount).map { 
                DateFormatter().monthSymbols[($0 - 1) % 12].prefix(3).uppercased()
            }
            
            var incomeByMonth = [Double](repeating: 0, count: monthCount)
            var expenseByMonth = [Double](repeating: 0, count: monthCount)
            
            let startMonth = calendar.component(.month, from: dateRange.start) - 1
            
            for item in income {
                var monthIndex = calendar.component(.month, from: item.date) - 1
                monthIndex = (monthIndex - startMonth + 12) % 12
                if monthIndex < monthCount {
                    incomeByMonth[monthIndex] += item.totalAmount()
                }
            }
            
            for item in expenses {
                var monthIndex = calendar.component(.month, from: item.date) - 1
                monthIndex = (monthIndex - startMonth + 12) % 12
                if monthIndex < monthCount {
                    expenseByMonth[monthIndex] += item.amount
                }
            }
            
            return (monthLabels, incomeByMonth, expenseByMonth)
        }
    }
}

// 儀表板數據模型
struct DashboardData {
    let period: Period
    let summary: DashboardSummary
    let metrics: DashboardMetrics
    let chartData: DashboardChartData
}

// 儀表板摘要數據
struct DashboardSummary {
    let totalIncome: Double
    let totalExpense: Double
    let netIncome: Double
    let incomeChangePercent: Double?
    let expenseChangePercent: Double?
    let netIncomeChangePercent: Double?
}

// 儀表板指標數據
struct DashboardMetrics {
    let hourlyRate: Double
    let costPerMile: Double
    let totalMileage: Double
    let totalWorkHours: Double
    let totalTaxDeductible: Double
}

// 儀表板圖表數據
struct DashboardChartData {
    let labels: [String]
    let incomeData: [Double]
    let expenseData: [Double]
}
