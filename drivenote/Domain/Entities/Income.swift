import Foundation

struct Income: Identifiable {
    var id: UUID
    var date: Date
    var amount: Double
    var tipAmount: Double
    var source: IncomeSource
    var notes: String?
    var isUploaded: Bool
    var lastModified: Date
    
    enum IncomeSource: String, CaseIterable, Identifiable {
        case uber = "Uber"
        case bolt = "Bolt"
        case freeNow = "FreeNow"
        case cash = "Cash"
        case other = "Other"
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .uber: return "Uber"
            case .bolt: return "Bolt"
            case .freeNow: return "Free Now"
            case .cash: return "現金"
            case .other: return "其他"
            }
        }
        
        var icon: String {
            switch self {
            case .uber: return "car.circle.fill"
            case .bolt: return "bolt.car.fill"
            case .freeNow: return "app.fill"
            case .cash: return "banknote.fill"
            case .other: return "square.grid.2x2.fill"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        amount: Double = 0.0,
        tipAmount: Double = 0.0,
        source: IncomeSource = .uber,
        notes: String? = nil,
        isUploaded: Bool = false,
        lastModified: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.tipAmount = tipAmount
        self.source = source
        self.notes = notes
        self.isUploaded = isUploaded
        self.lastModified = lastModified
    }
    
    // 計算總收入 (包含小費)
    func totalAmount() -> Double {
        return amount + tipAmount
    }
}

extension Income {
    static func mock() -> Income {
        let sources: [IncomeSource] = [.uber, .bolt, .freeNow, .cash, .other]
        let randomSource = sources.randomElement() ?? .uber
        
        return Income(
            date: Date().addingTimeInterval(-Double.random(in: 0...(86400 * 30))),
            amount: Double.random(in: 50...200),
            tipAmount: Double.random(in: 0...30),
            source: randomSource,
            notes: Bool.random() ? "繁忙時段" : nil,
            lastModified: Date()
        )
    }
    
    static func mockArray(count: Int = 10) -> [Income] {
        return (0..<count).map { _ in mock() }
    }
}
