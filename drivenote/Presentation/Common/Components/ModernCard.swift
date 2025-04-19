import SwiftUI

struct ModernCard<Content: View>: View {
    var title: String
    var icon: String?
    var tint: Color = .primaryBlue
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            if !title.isEmpty {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.headline)
                            .foregroundColor(tint)
                    }
                    
                    Text(title)
                        .font(.titleMedium)
                    
                    Spacer()
                }
            }
            
            content()
        }
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.medium)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct CardWithoutPadding<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        content()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct ModernCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ModernCard(title: "測試卡片", icon: "star.fill", tint: .primaryBlue) {
                Text("這是卡片內容")
                    .padding(.bottom, 8)
            }
            .padding()
            
            ModernCard(title: "", icon: nil) {
                Text("無標題卡片")
                    .padding()
            }
            .padding()
        }
    }
}
