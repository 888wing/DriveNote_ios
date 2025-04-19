import Foundation
import Combine

protocol IncomeRepository {
    // 獲取所有收入記錄
    func getAllIncome() -> AnyPublisher<[Income], Error>
    
    // 根據ID獲取收入記錄
    func getIncomeById(id: UUID) -> AnyPublisher<Income?, Error>
    
    // 根據日期範圍獲取收入記錄
    func getIncomeByDateRange(start: Date, end: Date) -> AnyPublisher<[Income], Error>
    
    // 根據收入來源獲取收入記錄
    func getIncomeBySource(source: Income.IncomeSource) -> AnyPublisher<[Income], Error>
    
    // 保存收入記錄
    func saveIncome(income: Income) -> AnyPublisher<Income, Error>
    
    // 刪除收入記錄
    func deleteIncome(id: UUID) -> AnyPublisher<Void, Error>
    
    // 同步收入記錄 (本地與雲端)
    func syncIncome() -> AnyPublisher<Void, Error>
    
    // 獲取未同步的收入記錄
    func getUnsyncedIncome() -> AnyPublisher<[Income], Error>
    
    // 標記收入為已同步
    func markIncomeAsSynced(id: UUID) -> AnyPublisher<Void, Error>
    
    // 獲取總收入 (指定日期範圍)
    func getTotalIncome(start: Date, end: Date) -> AnyPublisher<Double, Error>
    
    // 獲取總小費 (指定日期範圍)
    func getTotalTips(start: Date, end: Date) -> AnyPublisher<Double, Error>
}
