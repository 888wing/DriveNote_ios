import Foundation

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case fuel = "Fuel"
    case insurance = "Insurance"
    case maintenance = "Maintenance"
    case tax = "Tax"
    case license = "License"
    case parking = "Parking"
    case toll = "Toll"
    case cleaning = "Cleaning"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .fuel: return "燃料"
        case .insurance: return "保險"
        case .maintenance: return "維修"
        case .tax: return "稅務"
        case .license: return "牌照"
        case .parking: return "停車"
        case .toll: return "通行費"
        case .cleaning: return "清潔"
        case .other: return "其他"
        }
    }
    
    var icon: String {
        switch self {
        case .fuel: return "fuelpump.fill"
        case .insurance: return "checkerboard.shield"
        case .maintenance: return "wrench.fill"
        case .tax: return "percent"
        case .license: return "doc.text.fill"
        case .parking: return "parkingsign"
        case .toll: return "road.lanes"
        case .cleaning: return "spray.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var isTaxDeductible: Bool {
        switch self {
        case .fuel, .insurance, .maintenance, .tax, .license, .toll: return true
        case .parking, .cleaning, .other: return false
        }
    }
    
    var taxTip: String? {
        switch self {
        case .fuel:
            return "燃料支出通常可以100%抵稅，如果該車輛僅用於業務目的。若同時用於個人用途，則需按比例申報。"
        case .insurance:
            return "車輛保險費用可在業務用途範圍內抵稅。如果車輛同時用於個人用途，則需按業務使用比例申報。"
        case .maintenance:
            return "維修費用可以在業務使用範圍內抵稅。請保留所有維修收據作為證明。"
        case .tax:
            return "車輛稅可按業務使用比例抵稅。"
        case .license:
            return "私人出租車牌照費用通常可以全額抵稅。"
        case .toll, .parking:
            return "業務行程產生的通行費和停車費可以抵稅。個人用途產生的費用不可抵稅。"
        default:
            return nil
        }
    }
}
