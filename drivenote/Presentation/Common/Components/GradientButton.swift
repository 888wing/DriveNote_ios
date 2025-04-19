import SwiftUI

struct GradientButton: View {
    var title: String
    var icon: String?
    var action: () -> Void
    var isDisabled: Bool = false
    
    private var gradient: LinearGradient {
        if isDisabled {
            return LinearGradient(
                gradient: Gradient(colors: [.gray.opacity(0.6), .gray.opacity(0.7)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [.primaryBlue, .deepBlue]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                        .padding(.trailing, 4)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(gradient)
            .cornerRadius(14)
            .opacity(isDisabled ? 0.7 : 1)
            .shadow(color: isDisabled ? .gray.opacity(0.1) : Color.primaryBlue.opacity(0.3), 
                    radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isDisabled)
    }
}

// 按鈕動畫效果
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButton: View {
    var title: String
    var icon: String?
    var action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                        .padding(.trailing, 4)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(isDisabled ? .gray : .primaryBlue)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isDisabled ? Color.gray.opacity(0.3) : Color.primaryBlue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isDisabled)
    }
}

struct GradientButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            GradientButton(title: "保存", icon: "checkmark") {
                print("按鈕點擊")
            }
            
            GradientButton(title: "禁用按鈕", icon: "xmark", action: {}, isDisabled: true)
            
            SecondaryButton(title: "取消", icon: "arrow.left") {
                print("取消點擊")
            }
            
            SecondaryButton(title: "禁用次要按鈕", icon: "xmark", action: {}, isDisabled: true)
        }
        .padding()
    }
}
