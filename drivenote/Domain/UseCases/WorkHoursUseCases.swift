import Foundation
import Combine

// 保存工時用例
struct SaveWorkHoursUseCase {
    private let repository: WorkHoursRepository
    
    init(repository: WorkHoursRepository) {
        self.repository = repository
    }
    
    func execute(workHours: WorkHours) -> AnyPublisher<WorkHours, Error> {
        return repository.saveWorkHours(workHours: workHours)
    }
}

// 獲取工時列表用例
struct GetWorkHoursUseCase {
    private let repository: WorkHoursRepository
    
    init(repository: WorkHoursRepository) {
        self.repository = repository
    }
    
    func execute(dateRange: (Date, Date)? = nil) -> AnyPublisher<[WorkHours], Error> {
        if let (start, end) = dateRange {
            return repository.getWorkHoursByDateRange(start: start, end: end)
        } else {
            return repository.getAllWorkHours()
        }
    }
}

// 獲取今日工時用例
struct GetTodayWorkHoursUseCase {
    private let repository: WorkHoursRepository
    
    init(repository: WorkHoursRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<WorkHours?, Error> {
        return repository.getTodayWorkHours()
    }
}

// 刪除工時用例
struct DeleteWorkHoursUseCase {
    private let repository: WorkHoursRepository
    
    init(repository: WorkHoursRepository) {
        self.repository = repository
    }
    
    func execute(id: UUID) -> AnyPublisher<Void, Error> {
        return repository.deleteWorkHours(id: id)
    }
}

// 計算時薪用例
struct CalculateHourlyRateUseCase {
    private let workHoursRepository: WorkHoursRepository
    private let incomeRepository: IncomeRepository
    
    init(workHoursRepository: WorkHoursRepository, incomeRepository: IncomeRepository) {
        self.workHoursRepository = workHoursRepository
        self.incomeRepository = incomeRepository
    }
    
    func execute(dateRange: (Date, Date)) -> AnyPublisher<HourlyRateAnalytics, Error> {
        let (start, end) = dateRange
        
        // 獲取指定日期範圍的總工時
        let totalHoursPublisher = workHoursRepository.getTotalWorkHours(start: start, end: end)
        
        // 獲取指定日期範圍的總收入
        let totalIncomePublisher = incomeRepository.getTotalIncome(start: start, end: end)
        
        // 獲取小費收入
        let totalTipsPublisher = incomeRepository.getTotalTips(start: start, end: end)
        
        // 組合結果
        return Publishers.CombineLatest3(totalHoursPublisher, totalIncomePublisher, totalTipsPublisher)
            .map { (totalHours, totalIncome, totalTips) in
                // 計算時薪
                let hourlyRate = totalHours > 0 ? (totalIncome / totalHours) : 0
                let hourlyRateWithoutTips = totalHours > 0 ? ((totalIncome - totalTips) / totalHours) : 0
                
                return HourlyRateAnalytics(
                    totalHours: totalHours,
                    totalIncome: totalIncome,
                    totalTips: totalTips,
                    hourlyRate: hourlyRate,
                    hourlyRateWithoutTips: hourlyRateWithoutTips
                )
            }
            .eraseToAnyPublisher()
    }
}

// 時薪分析結果模型
struct HourlyRateAnalytics {
    let totalHours: Double
    let totalIncome: Double
    let totalTips: Double
    let hourlyRate: Double
    let hourlyRateWithoutTips: Double
    
    // 計算小費佔收入比例
    var tipsPercentage: Double {
        guard totalIncome > 0 else { return 0 }
        return (totalTips / totalIncome) * 100.0
    }
}
