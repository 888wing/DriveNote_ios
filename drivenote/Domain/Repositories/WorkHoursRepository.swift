import Foundation
import Combine

protocol WorkHoursRepository {
    // 獲取所有工時記錄
    func getAllWorkHours() -> AnyPublisher<[WorkHours], Error>
    
    // 根據ID獲取工時記錄
    func getWorkHoursById(id: UUID) -> AnyPublisher<WorkHours?, Error>
    
    // 根據日期範圍獲取工時記錄
    func getWorkHoursByDateRange(start: Date, end: Date) -> AnyPublisher<[WorkHours], Error>
    
    // 保存工時記錄
    func saveWorkHours(workHours: WorkHours) -> AnyPublisher<WorkHours, Error>
    
    // 刪除工時記錄
    func deleteWorkHours(id: UUID) -> AnyPublisher<Void, Error>
    
    // 同步工時記錄 (本地與雲端)
    func syncWorkHours() -> AnyPublisher<Void, Error>
    
    // 獲取未同步的工時記錄
    func getUnsyncedWorkHours() -> AnyPublisher<[WorkHours], Error>
    
    // 標記工時為已同步
    func markWorkHoursAsSynced(id: UUID) -> AnyPublisher<Void, Error>
    
    // 獲取總工時 (指定日期範圍)
    func getTotalWorkHours(start: Date, end: Date) -> AnyPublisher<Double, Error>
    
    // 獲取今日工時記錄 (如果存在)
    func getTodayWorkHours() -> AnyPublisher<WorkHours?, Error>
}
