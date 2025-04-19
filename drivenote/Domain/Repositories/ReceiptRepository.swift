import Foundation
import Combine
import UIKit

protocol ReceiptRepository {
    // 獲取所有收據記錄
    func getAllReceipts() -> AnyPublisher<[Receipt], Error>
    
    // 根據ID獲取收據記錄
    func getReceiptById(id: UUID) -> AnyPublisher<Receipt?, Error>
    
    // 根據支出ID獲取收據記錄
    func getReceiptsByExpenseId(expenseId: UUID) -> AnyPublisher<[Receipt], Error>
    
    // 保存收據 (包含圖片數據)
    func saveReceipt(receipt: Receipt, imageData: Data) -> AnyPublisher<Receipt, Error>
    
    // 獲取收據圖片數據
    func getReceiptImage(receipt: Receipt) -> AnyPublisher<UIImage?, Error>
    
    // 刪除收據
    func deleteReceipt(id: UUID) -> AnyPublisher<Void, Error>
    
    // 處理收據OCR (發送圖片到OCR服務)
    func processReceiptWithOCR(receipt: Receipt) -> AnyPublisher<Receipt, Error>
    
    // 更新收據OCR狀態
    func updateReceiptOCRStatus(id: UUID, status: Receipt.OCRStatus, resultJson: String?) -> AnyPublisher<Receipt, Error>
    
    // 同步收據 (本地與雲端)
    func syncReceipts() -> AnyPublisher<Void, Error>
    
    // 獲取未同步的收據
    func getUnsyncedReceipts() -> AnyPublisher<[Receipt], Error>
    
    // 標記收據為已同步
    func markReceiptAsSynced(id: UUID) -> AnyPublisher<Void, Error>
    
    // 獲取待處理OCR的收據
    func getPendingOCRReceipts() -> AnyPublisher<[Receipt], Error>
}
