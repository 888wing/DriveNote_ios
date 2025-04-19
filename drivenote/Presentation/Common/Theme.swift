import SwiftUI

// MARK: - 色彩系統
extension Color {
    static let primaryBackground = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    
    // 主色調 - 深藍色，穩重專業
    static let primaryBlue = Color(hex: "0A84FF")
    static let deepBlue = Color(hex: "0050C5")
    
    // 強調色 - 清新綠色，象徵收入/利潤
    static let accentGreen = Color(hex: "30D158")
    static let deepGreen = Color(hex: "248A3D")
    
    // 警示色 - 支出用橙色
    static let expenseOrange = Color(hex: "FF9500")
    static let deepOrange = Color(hex: "C93400")
    
    // 中性色調
    static let neutralGray = Color(hex: "8E8E93")
    static let lightGray = Color(hex: "E5E5EA")
    
    // Color from hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 排版系統
extension Font {
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let titleLarge = Font.system(size: 22, weight: .bold)
    static let titleMedium = Font.system(size: 17, weight: .semibold)
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 13, weight: .medium)
    static let overline = Font.system(size: 12, weight: .semibold)
    
    // 數字顯示專用字體
    static let monoLarge = Font.system(size: 34, weight: .medium, design: .monospaced)
    static let monoMedium = Font.system(size: 22, weight: .medium, design: .monospaced)
}

// MARK: - 間距系統
struct Spacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let huge: CGFloat = 32
}

// MARK: - 陰影
struct Shadows {
    static let small = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    static let large = Shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
}
