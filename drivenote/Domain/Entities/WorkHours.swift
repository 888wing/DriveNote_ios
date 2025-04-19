import Foundation

struct WorkHours: Identifiable {
    var id: UUID
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var totalHours: Double
    var isUploaded: Bool
    var lastModified: Date
    var notes: String?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        startTime: Date? = nil,
        endTime: Date? = nil,
        totalHours: Double = 0.0,
        isUploaded: Bool = false,
        lastModified: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.totalHours = totalHours
        self.isUploaded = isUploaded
        self.lastModified = lastModified
        self.notes = notes
    }
    
    // 從開始和結束時間計算總工時
    mutating func calculateTotalHours() {
        if let start = startTime, let end = endTime {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: start, to: end)
            let hours = Double(components.hour ?? 0)
            let minutes = Double(components.minute ?? 0) / 60.0
            totalHours = hours + minutes
        }
    }
    
    // 格式化總工時顯示
    func formattedTotalHours() -> String {
        let hours = Int(totalHours)
        let minutes = Int((totalHours - Double(hours)) * 60)
        return String(format: "%d時%02d分", hours, minutes)
    }
}

extension WorkHours {
    static func mock() -> WorkHours {
        let mockDate = Date().addingTimeInterval(-Double.random(in: 0...(86400 * 30)))
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: mockDate)
        
        // 設置隨機開始時間 (7:00 - 14:00)
        dateComponents.hour = Int.random(in: 7...14)
        dateComponents.minute = Int.random(in: 0...59)
        let startTime = calendar.date(from: dateComponents)!
        
        // 設置隨機結束時間 (開始時間後 4-8 小時)
        let hoursToAdd = Double.random(in: 4...8)
        let endTime = startTime.addingTimeInterval(hoursToAdd * 3600)
        
        var workHours = WorkHours(
            date: mockDate,
            startTime: startTime,
            endTime: endTime,
            isUploaded: false,
            lastModified: Date(),
            notes: Bool.random() ? "繁忙時段" : nil
        )
        
        workHours.calculateTotalHours()
        return workHours
    }
    
    static func mockArray(count: Int = 10) -> [WorkHours] {
        return (0..<count).map { _ in mock() }
    }
}
