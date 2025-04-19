import Foundation
import Combine

// 保存里程用例
struct SaveMileageUseCase {
    private let repository: MileageRepository
    
    init(repository: MileageRepository) {
        self.repository = repository
    }
    
    func execute(mileage: Mileage) -> AnyPublisher<Mileage, Error> {
        return repository.saveMileage(mileage: mileage)
    }
}

// 獲取里程列表用例
struct GetMileageUseCase {
    private let repository: MileageRepository
    
    init(repository: MileageRepository) {
        self.repository = repository
    }
    
    func execute(dateRange: (Date, Date)? = nil) -> AnyPublisher<[Mileage], Error> {
        if let (start, end) = dateRange {
            return repository.getMileageByDateRange(start: start, end: end)
        } else {
            return repository.getAllMileage()
        }
    }
}

// 獲取里程詳情用例
struct GetMileageDetailsUseCase {
    private let mileageRepository: MileageRepository
    private let expenseRepository: ExpenseRepository
    
    init(mileageRepository: MileageRepository, expenseRepository: ExpenseRepository) {
        self.mileageRepository = mileageRepository
        self.expenseRepository = expenseRepository
    }
    
    func execute(id: UUID) -> AnyPublisher<(Mileage, Expense?), Error> {
        return mileageRepository.getMileageById(id: id)
            .compactMap { $0 }
            .flatMap { mileage -> AnyPublisher<(Mileage, Expense?), Error> in
                if let expenseId = mileage.relatedFuelExpenseId {
                    return expenseRepository.getExpenseById(id: expenseId)
                        .map { expense in
                            return (mileage, expense)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just((mileage, nil))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

// 刪除里程用例
struct DeleteMileageUseCase {
    private let repository: MileageRepository
    
    init(repository: MileageRepository) {
        self.repository = repository
    }
    
    func execute(id: UUID) -> AnyPublisher<Void, Error> {
        return repository.deleteMileage(id: id)
    }
}

// 計算里程成本用例
struct CalculateMileageCostUseCase {
    private let mileageRepository: MileageRepository
    private let expenseRepository: ExpenseRepository
    
    init(mileageRepository: MileageRepository, expenseRepository: ExpenseRepository) {
        self.mileageRepository = mileageRepository
        self.expenseRepository = expenseRepository
    }
    
    func execute(dateRange: (Date, Date)) -> AnyPublisher<MileageCost, Error> {
        let (start, end) = dateRange
        
        // 獲取指定日期範圍的總里程
        let totalMileagePublisher = mileageRepository.getTotalMileage(start: start, end: end)
        
        // 獲取指定日期範圍的燃料支出
        let fuelExpensesPublisher = expenseRepository.getExpensesByDateRange(start: start, end: end)
            .map { expenses in
                return expenses.filter { $0.category == .fuel }
            }
        
        // 組合兩個結果
        return Publishers.CombineLatest(totalMileagePublisher, fuelExpensesPublisher)
            .map { (totalMileage, fuelExpenses) in
                let totalFuelCost = fuelExpenses.reduce(0) { $0 + $1.amount }
                
                // 計算每英里成本
                let costPerMile = totalMileage > 0 ? totalFuelCost / totalMileage : 0
                
                return MileageCost(
                    totalMileage: totalMileage,
                    totalFuelCost: totalFuelCost,
                    costPerMile: costPerMile
                )
            }
            .eraseToAnyPublisher()
    }
}

// 里程成本分析結果模型
struct MileageCost {
    let totalMileage: Double
    let totalFuelCost: Double
    let costPerMile: Double
}
