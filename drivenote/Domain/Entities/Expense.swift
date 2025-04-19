import Foundation

struct Expense: Identifiable {
    var id: UUID
    var date: Date
    var amount: Double
    var category: ExpenseCategory
    var description: String?
    var isTaxDeductible: Bool
    var taxDeductiblePercentage: Int // 0-100
    var creationMethod: CreationMethod
    var isUploaded: Bool
    var lastModified: Date
    
    // 關聯
    var receiptIds: [UUID]?
    var relatedMileageId: UUID?
    
    enum CreationMethod: String, Codable {
        case manual = "manual"
        case ocr = "ocr"
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        amount: Double = 0.0,
        category: ExpenseCategory = .other,
        description: String? = nil,
        isTaxDeductible: Bool = false,
        taxDeductiblePercentage: Int = 100,
        creationMethod: CreationMethod = .manual,
        isUploaded: Bool = false,
        lastModified: Date = Date(),
        receiptIds: [UUID]? = nil,
        relatedMileageId: UUID? = nil
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.category = category
        self.description = description
        self.isTaxDeductible = isTaxDeductible
        self.taxDeductiblePercentage = taxDeductiblePercentage
        self.creationMethod = creationMethod
        self.isUploaded = isUploaded
        self.lastModified = lastModified
        self.receiptIds = receiptIds
        self.relatedMileageId = relatedMileageId
    }
    
    // 計算可抵稅金額
    func taxDeductibleAmount() -> Double {
        if isTaxDeductible {
            return amount * Double(taxDeductiblePercentage) / 100.0
        }
        return 0.0
    }
}

extension Expense {
    static func mock() -> Expense {
        let categories: [ExpenseCategory] = [.fuel, .maintenance, .insurance, .other]
        let randomCategory = categories.randomElement() ?? .other
        
        return Expense(
            date: Date().addingTimeInterval(-Double.random(in: 0...(86400 * 30))),
            amount: Double.random(in: 10...200),
            category: randomCategory,
            description: "測試支出",
            isTaxDeductible: randomCategory != .other,
            taxDeductiblePercentage: randomCategory == .other ? 0 : Int.random(in: 0...10) * 10,
            lastModified: Date()
        )
    }
    
    static func mockArray(count: Int = 10) -> [Expense] {
        return (0..<count).map { _ in mock() }
    }
}
