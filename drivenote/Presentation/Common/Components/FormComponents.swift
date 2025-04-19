import SwiftUI

struct ModernTextField: View {
    var label: String
    var icon: String
    var placeholder: String = ""
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.lightGray, lineWidth: 1)
            )
        }
        .padding(.bottom, 8)
    }
}

struct CurrencyInputField: View {
    var label: String
    var icon: String
    @Binding var value: Double?
    
    // 用於處理文本輸入的狀態
    @State private var textValue: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                Text("£")
                    .foregroundColor(.secondary)
                    .padding(.trailing, 2)
                
                TextField("0.00", text: $textValue)
                    .keyboardType(.decimalPad)
                    .onChange(of: textValue) { newValue in
                        // 過濾非數字和小數點字符
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            textValue = filtered
                        }
                        
                        // 轉換為Double
                        if let doubleValue = Double(filtered) {
                            value = doubleValue
                        } else if filtered.isEmpty {
                            value = nil
                        }
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.lightGray, lineWidth: 1)
            )
        }
        .padding(.bottom, 8)
        .onAppear {
            // 初始化文本值
            if let value = value {
                textValue = String(format: "%.2f", value)
            }
        }
    }
}

struct DatePickerField: View {
    var label: String
    var icon: String
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .labelsHidden()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.lightGray, lineWidth: 1)
            )
        }
        .padding(.bottom, 8)
    }
}

struct CategoryButton: View {
    var title: String
    var icon: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.primaryBlue : Color(.tertiarySystemBackground))
                    .cornerRadius(15)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primaryBlue : .primary)
            }
        }
    }
}

struct FormComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ModernTextField(
                    label: "描述",
                    icon: "text.alignleft",
                    placeholder: "輸入描述",
                    text: .constant("測試描述")
                )
                
                CurrencyInputField(
                    label: "金額",
                    icon: "sterling.sign",
                    value: .constant(123.45)
                )
                
                DatePickerField(
                    label: "日期",
                    icon: "calendar",
                    date: .constant(Date())
                )
                
                HStack {
                    CategoryButton(
                        title: "燃料",
                        icon: "fuelpump.fill",
                        isSelected: true,
                        action: {}
                    )
                    
                    CategoryButton(
                        title: "維修",
                        icon: "wrench.fill",
                        isSelected: false,
                        action: {}
                    )
                }
            }
            .padding()
        }
    }
}
