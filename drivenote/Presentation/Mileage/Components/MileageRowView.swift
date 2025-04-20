import SwiftUI

struct MileageRowView: View {
    let mileage: Mileage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(mileage.purpose ?? "未指定目的")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\(mileage.distance, specifier: "%.1f") 公里")
                    .font(.headline)
                    .foregroundColor(.primaryBlue)
            }
            
            HStack {
                // 日期
                Label(dateFormatter.string(from: mileage.date), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 稅務狀態
                if mileage.isTaxDeductible {
                    Label(
                        "\(mileage.taxDeductiblePercentage)% 可抵稅",
                        systemImage: "percent"
                    )
                    .font(.caption)
                    .foregroundColor(mileage.taxDeductiblePercentage == 100 ? .accentGreen : .expenseOrange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                mileage.taxDeductiblePercentage == 100 ? 
                                Color.accentGreen.opacity(0.1) : 
                                Color.expenseOrange.opacity(0.1)
                            )
                    )
                }
            }
            
            // 顯示起始和結束里程（如果有）
            if let start = mileage.startMileage, let end = mileage.endMileage {
                HStack {
                    Text("\(start, specifier: "%.1f") → \(end, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

struct MileageRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MileageRowView(
                mileage: Mileage(
                    id: UUID(),
                    date: Date(),
                    startMileage: 10000,
                    endMileage: 10045,
                    distance: 45,
                    purpose: "市區接送",
                    isUploaded: false,
                    lastModified: Date(),
                    isTaxDeductible: true,
                    taxDeductiblePercentage: 100
                )
            )
            
            MileageRowView(
                mileage: Mileage(
                    id: UUID(),
                    date: Date().addingTimeInterval(-86400),
                    startMileage: nil,
                    endMileage: nil,
                    distance: 38.5,
                    purpose: "機場接送",
                    isUploaded: false,
                    lastModified: Date(),
                    isTaxDeductible: true,
                    taxDeductiblePercentage: 50
                )
            )
        }
        .listStyle(InsetGroupedListStyle())
        .previewLayout(.sizeThatFits)
    }
}
