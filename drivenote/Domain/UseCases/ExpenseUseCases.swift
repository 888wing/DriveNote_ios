import Foundation
import Combine

// 保存支出用例
struct SaveExpenseUseCase {
    private let repository: ExpenseRepository
    
    init(repository: ExpenseRepository) {
        self.repository = repository
    }
    
    func execute(expense: Expense) -> AnyPublisher<Expense, Error> {
        return repository.saveExpense(expense: expense)
    }
}

// 獲取支出列表用例
struct GetExpensesUseCase {
    private let repository: ExpenseRepository
    
    init(repository: ExpenseRepository) {
        self.repository = repository
    }
    
    func execute(dateRange: (Date, Date)? = nil) -> AnyPublisher<[Expense], Error> {
        if let (start, end) = dateRange {
            return repository.getExpensesByDateRange(start: start, end: end)
        } else {
            return repository.getAllExpenses()
        }
    }
}

// 獲取支出詳情用例
struct GetExpenseDetailsUseCase {
    private let expenseRepository: ExpenseRepository
    private let receiptRepository: ReceiptRepository
    
    init(expenseRepository: ExpenseRepository, receiptRepository: ReceiptRepository) {
        self.expenseRepository = expenseRepository
        self.receiptRepository = receiptRepository
    }
    
    func execute(id: UUID) -> AnyPublisher<(Expense, [Receipt]), Error> {
        return expenseRepository.getExpenseById(id: id)
            .compactMap { expense -> Expense? in
                return expense
            }
            .flatMap { expense -> AnyPublisher<(Expense, [Receipt]), Error> in
                if let receiptIds = expense.receiptIds, !receiptIds.isEmpty {
                    return Publishers.MergeMany(
                        receiptIds.map { receiptId in
                            return receiptRepository.getReceiptById(id: receiptId)
                                .compactMap { $0 }
                        }
                    )
                    .collect()
                    .map { receipts in
                        return (expense, receipts)
                    }
                    .eraseToAnyPublisher()
                } else {
                    return Just((expense, [Receipt]()))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

// 刪除支出用例
struct DeleteExpenseUseCase {
    private let repository: ExpenseRepository
    
    init(repository: ExpenseRepository) {
        self.repository = repository
    }
    
    func execute(id: UUID) -> AnyPublisher<Void, Error> {
        return repository.deleteExpense(id: id)
    }
}

// 分析支出用例
struct AnalyzeExpensesUseCase {
    private let repository: ExpenseRepository
    
    init(repository: ExpenseRepository) {
        self.repository = repository
    }
    
    func execute(dateRange: (Date, Date)) -> AnyPublisher<ExpenseAnalytics, Error> {
        let (start, end) = dateRange
        
        return repository.getExpensesByDateRange(start: start, end: end)
            .map { expenses in
                // 計算支出分析
                var totalExpense = 0.0
                var totalTaxDeductible = 0.0
                var expensesByCategory = [ExpenseCategory: Double]()
                
                for expense in expenses {
                    totalExpense += expense.amount
                    totalTaxDeductible += expense.taxDeductibleAmount()
                    
                    // 按類別分組
                    let currentAmount = expensesByCategory[expense.category] ?? 0.0
                    expensesByCategory[expense.category] = currentAmount + expense.amount
                }
                
                return ExpenseAnalytics(
                    totalExpense: totalExpense,
                    totalTaxDeductible: totalTaxDeductible,
                    expensesByCategory: expensesByCategory
                )
            }
            .eraseToAnyPublisher()
    }
}

// 支出分析結果模型
struct ExpenseAnalytics {
    let totalExpense: Double
    let totalTaxDeductible: Double
    let expensesByCategory: [ExpenseCategory: Double]
    
    // 計算可抵稅比例
    var taxDeductiblePercentage: Double {
        guard totalExpense > 0 else { return 0 }
        return (totalTaxDeductible / totalExpense) * 100.0
    }
    
    // 獲取按金額排序的支出類別
    var topCategories: [(category: ExpenseCategory, amount: Double)] {
        return expensesByCategory.sorted { $0.value > $1.value }
    }
}
