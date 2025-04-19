import Foundation

enum Period: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .day: return "今日"
        case .week: return "本週"
        case .month: return "本月"
        case .quarter: return "本季"
        case .year: return "本年"
        }
    }
    
    func dateRange(from date: Date = Date()) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        
        switch self {
        case .day:
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return (startOfDay, endOfDay)
            
        case .week:
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            let startOfWeek = calendar.date(from: components)!
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
            return (startOfWeek, endOfWeek)
            
        case .month:
            let components = calendar.dateComponents([.year, .month], from: date)
            let startOfMonth = calendar.date(from: components)!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: 0), to: startOfMonth)!
            return (startOfMonth, endOfMonth)
            
        case .quarter:
            let currentMonth = calendar.component(.month, from: date)
            let quarterNumber = ((currentMonth - 1) / 3) + 1
            let startMonth = (quarterNumber - 1) * 3 + 1
            
            var startComponents = calendar.dateComponents([.year], from: date)
            startComponents.month = startMonth
            startComponents.day = 1
            let startOfQuarter = calendar.date(from: startComponents)!
            
            let endOfQuarter = calendar.date(byAdding: DateComponents(month: 3, day: 0), to: startOfQuarter)!
            return (startOfQuarter, endOfQuarter)
            
        case .year:
            var components = calendar.dateComponents([.year], from: date)
            components.month = 1
            components.day = 1
            let startOfYear = calendar.date(from: components)!
            
            components.year! += 1
            let startOfNextYear = calendar.date(from: components)!
            return (startOfYear, startOfNextYear)
        }
    }
}
