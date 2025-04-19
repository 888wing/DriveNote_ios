import Foundation
import Combine

protocol MileageRepository {
    // 獲取所有里程記錄
    func getAllMileage() -> AnyPublisher<[Mileage], Error>
    
    // 根據ID獲取里程記錄
    func getMileageById(id: UUID) -> AnyPublisher<Mileage?, Error>
    
    // 根據日期範圍獲取里程記錄
    func getMileageByDateRange(start: Date, end: Date) -> AnyPublisher<[Mileage], Error>
    
    // 保存里程記錄
    func saveMileage(mileage: Mileage) -> AnyPublisher<Mileage, Error>
    
    // 刪除里程記錄
    func deleteMileage(id: UUID) -> AnyPublisher<Void, Error>
    
    // 同步里程記錄 (本地與雲端)
    func syncMileage() -> AnyPublisher<Void, Error>
    
    // 獲取未同步的里程記錄
    func getUnsyncedMileage() -> AnyPublisher<[Mileage], Error>
    
    // 標記里程為已同步
    func markMileageAsSynced(id: UUID) -> AnyPublisher<Void, Error>
    
    // 獲取總里程 (指定日期範圍)
    func getTotalMileage(start: Date, end: Date) -> AnyPublisher<Double, Error>
    
    // 根據關聯的燃料支出ID獲取里程記錄
    func getMileageByFuelExpenseId(expenseId: UUID) -> AnyPublisher<[Mileage], Error>
}
