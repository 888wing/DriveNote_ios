import Foundation

struct Mileage: Identifiable {
    var id: UUID
    var date: Date
    var startMileage: Double?
    var endMileage: Double?
    var distance: Double
    var purpose: String?
    var isUploaded: Bool
    var lastModified: Date
    var isTaxDeductible: Bool
    var taxDeductiblePercentage: Int // 0-100
    
    // 關聯
    var relatedFuelExpenseId: UUID?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        startMileage: Double? = nil,
        endMileage: Double? = nil,
        distance: Double = 0.0,
        purpose: String? = nil,
        isUploaded: Bool = false,
        lastModified: Date = Date(),
        isTaxDeductible: Bool = true,
        taxDeductiblePercentage: Int = 100,
        relatedFuelExpenseId: UUID? = nil
    ) {
        self.id = id
        self.date = date
        self.startMileage = startMileage
        self.endMileage = endMileage
        self.distance = distance
        self.purpose = purpose
        self.isUploaded = isUploaded
        self.lastModified = lastModified
        self.isTaxDeductible = isTaxDeductible
        self.taxDeductiblePercentage = taxDeductiblePercentage
        self.relatedFuelExpenseId = relatedFuelExpenseId
    }
    
    // 計算可抵稅里程
    func taxDeductibleMileage() -> Double {
        if isTaxDeductible {
            return distance * Double(taxDeductiblePercentage) / 100.0
        }
        return 0.0
    }
    
    // 使用起始和結束里程計算總里程
    mutating func calculateDistance() {
        if let start = startMileage, let end = endMileage {
            distance = end - start
        }
    }
}

extension Mileage {
    static func mock() -> Mileage {
        let randomDistance = Double.random(in: 5...100)
        let mockEndMileage = Double.random(in: 50000...60000)
        let mockStartMileage = mockEndMileage - randomDistance
        
        return Mileage(
            date: Date().addingTimeInterval(-Double.random(in: 0...(86400 * 30))),
            startMileage: mockStartMileage,
            endMileage: mockEndMileage,
            distance: randomDistance,
            purpose: ["機場接送", "市中心工作", "長途旅行", "日常上下班"][Int.random(in: 0...3)],
            lastModified: Date(),
            isTaxDeductible: Bool.random(),
            taxDeductiblePercentage: Int.random(in: 0...10) * 10
        )
    }
    
    static func mockArray(count: Int = 10) -> [Mileage] {
        return (0..<count).map { _ in mock() }
    }
}
