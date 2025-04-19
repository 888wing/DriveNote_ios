import Foundation
import Combine
import UIKit

// 保存收據用例
struct SaveReceiptUseCase {
    private let repository: ReceiptRepository
    
    init(repository: ReceiptRepository) {
        self.repository = repository
    }
    
    func execute(receipt: Receipt, imageData: Data) -> AnyPublisher<Receipt, Error> {
        return repository.saveReceipt(receipt: receipt, imageData: imageData)
    }
}

// 處理收據OCR用例
struct ProcessReceiptOCRUseCase {
    private let repository: ReceiptRepository
    
    init(repository: ReceiptRepository) {
        self.repository = repository
    }
    
    func execute(receipt: Receipt) -> AnyPublisher<Receipt, Error> {
        return repository.processReceiptWithOCR(receipt: receipt)
    }
}

// 將OCR結果轉換為支出用例
struct ConvertOCRToExpenseUseCase {
    private let receiptRepository: ReceiptRepository
    private let expenseRepository: ExpenseRepository
    
    init(receiptRepository: ReceiptRepository, expenseRepository: ExpenseRepository) {
        self.receiptRepository = receiptRepository
        self.expenseRepository = expenseRepository
    }
    
    func execute(receiptId: UUID) -> AnyPublisher<Expense, Error> {
        return receiptRepository.getReceiptById(id: receiptId)
            .compactMap { $0 }
            .flatMap { receipt -> AnyPublisher<Expense, Error> in
                guard let ocrResult = receipt.parseOCRResult() else {
                    return Fail(error: NSError(domain: "OCR結果解析失敗", code: -1))
                        .eraseToAnyPublisher()
                }
                
                // 根據OCR結果創建支出
                var category: ExpenseCategory = .other
                if let categoryStr = ocrResult.category {
                    if categoryStr.lowercased().contains("fuel") {
                        category = .fuel
                    } else if categoryStr.lowercased().contains("insurance") {
                        category = .insurance
                    } else if categoryStr.lowercased().contains("maintenance") {
                        category = .maintenance
                    }
                }
                
                let expense = Expense(
                    date: ocrResult.date ?? Date(),
                    amount: ocrResult.totalAmount ?? 0.0,
                    category: category,
                    description: ocrResult.vendorName,
                    isTaxDeductible: category.isTaxDeductible,
                    taxDeductiblePercentage: 100,
                    creationMethod: .ocr,
                    isUploaded: false,
                    lastModified: Date(),
                    receiptIds: [receipt.id]
                )
                
                return expenseRepository.saveExpense(expense: expense)
            }
            .eraseToAnyPublisher()
    }
}

// 獲取收據圖片用例
struct GetReceiptImageUseCase {
    private let repository: ReceiptRepository
    
    init(repository: ReceiptRepository) {
        self.repository = repository
    }
    
    func execute(receipt: Receipt) -> AnyPublisher<UIImage?, Error> {
        return repository.getReceiptImage(receipt: receipt)
    }
}

// 刪除收據用例
struct DeleteReceiptUseCase {
    private let repository: ReceiptRepository
    
    init(repository: ReceiptRepository) {
        self.repository = repository
    }
    
    func execute(id: UUID) -> AnyPublisher<Void, Error> {
        return repository.deleteReceipt(id: id)
    }
}

// 獲取未處理OCR的收據用例
struct GetPendingOCRReceiptsUseCase {
    private let repository: ReceiptRepository
    
    init(repository: ReceiptRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[Receipt], Error> {
        return repository.getPendingOCRReceipts()
    }
}
