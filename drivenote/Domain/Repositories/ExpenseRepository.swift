import Foundation
import Combine

protocol ExpenseRepository {
    // 獲取所有支出記錄
    func getAllExpenses() -> AnyPublisher<[Expense], Error>
    
    // 根據ID獲取支出記錄
    func getExpenseById(id: UUID) -> AnyPublisher<Expense?, Error>
    
    // 根據日期範圍獲取支出記錄
    func getExpensesByDateRange(start: Date, end: Date) -> AnyPublisher<[Expense], Error>
    
    // 根據類別獲取支出記錄
    func getExpensesByCategory(category: ExpenseCategory) -> AnyPublisher<[Expense], Error>
    
    // 保存支出記錄
    func saveExpense(expense: Expense) -> AnyPublisher<Expense, Error>
    
    // 刪除支出記錄
    func deleteExpense(id: UUID) -> AnyPublisher<Void, Error>
    
    // 同步支出記錄 (本地與雲端)
    func syncExpenses() -> AnyPublisher<Void, Error>
    
    // 獲取未同步的支出記錄
    func getUnsyncedExpenses() -> AnyPublisher<[Expense], Error>
    
    // 標記支出為已同步
    func markExpenseAsSynced(id: UUID) -> AnyPublisher<Void, Error>
    
    // 根據收據ID獲取關聯的支出
    func getExpenseByReceiptId(receiptId: UUID) -> AnyPublisher<Expense?, Error>
}
