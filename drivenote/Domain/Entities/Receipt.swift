import Foundation

struct Receipt: Identifiable {
    var id: UUID
    var filePath: String
    var uploadTimestamp: Date
    var ocrStatus: OCRStatus
    var ocrResultJson: String?
    var isUploaded: Bool
    
    // 關聯
    var expenseId: UUID?
    
    enum OCRStatus: String, Codable {
        case pending = "pending"
        case processing = "processing"
        case completed = "completed"
        case failed = "failed"
        
        var displayName: String {
            switch self {
            case .pending: return "待處理"
            case .processing: return "處理中"
            case .completed: return "已完成"
            case .failed: return "處理失敗"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        filePath: String,
        uploadTimestamp: Date = Date(),
        ocrStatus: OCRStatus = .pending,
        ocrResultJson: String? = nil,
        isUploaded: Bool = false,
        expenseId: UUID? = nil
    ) {
        self.id = id
        self.filePath = filePath
        self.uploadTimestamp = uploadTimestamp
        self.ocrStatus = ocrStatus
        self.ocrResultJson = ocrResultJson
        self.isUploaded = isUploaded
        self.expenseId = expenseId
    }
    
    // 從OCR結果中解析收據信息
    func parseOCRResult() -> OCRResult? {
        guard let jsonString = ocrResultJson,
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let result = try JSONDecoder().decode(OCRResult.self, from: data)
            return result
        } catch {
            print("解析OCR結果失敗: \(error)")
            return nil
        }
    }
}

// OCR結果模型
struct OCRResult: Codable {
    var vendorName: String?
    var date: Date?
    var totalAmount: Double?
    var taxAmount: Double?
    var category: String?
    var items: [OCRItem]?
    
    struct OCRItem: Codable {
        var description: String
        var quantity: Int?
        var unitPrice: Double?
        var amount: Double?
    }
}

extension Receipt {
    static func mock() -> Receipt {
        let mockId = UUID()
        let fileExtension = ["jpg", "png", "jpeg"].randomElement() ?? "jpg"
        let mockFilePath = "receipts/\(mockId.uuidString).\(fileExtension)"
        
        let statuses: [OCRStatus] = [.pending, .processing, .completed, .failed]
        let randomStatus = statuses.randomElement() ?? .pending
        
        var mockOCRJson: String? = nil
        if randomStatus == .completed {
            // 模擬OCR結果
            let vendorNames = ["Shell", "BP", "Esso", "Texaco", "Total", "Sainsbury's", "Tesco", "Morrisons"]
            let randomVendor = vendorNames.randomElement() ?? "Unknown Vendor"
            
            let mockResult = OCRResult(
                vendorName: randomVendor,
                date: Date().addingTimeInterval(-Double.random(in: 0...(86400 * 30))),
                totalAmount: Double.random(in: 30...150),
                taxAmount: Double.random(in: 5...30),
                category: "Fuel",
                items: [
                    OCRResult.OCRItem(
                        description: "Unleaded Petrol",
                        quantity: Int.random(in: 20...50),
                        unitPrice: Double.random(in: 1.30...1.60),
                        amount: Double.random(in: 30...80)
                    )
                ]
            )
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            if let data = try? encoder.encode(mockResult) {
                mockOCRJson = String(data: data, encoding: .utf8)
            }
        }
        
        return Receipt(
            id: mockId,
            filePath: mockFilePath,
            uploadTimestamp: Date().addingTimeInterval(-Double.random(in: 0...(86400 * 7))),
            ocrStatus: randomStatus,
            ocrResultJson: mockOCRJson,
            isUploaded: Bool.random()
        )
    }
    
    static func mockArray(count: Int = 5) -> [Receipt] {
        return (0..<count).map { _ in mock() }
    }
}
