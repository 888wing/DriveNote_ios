import SwiftUI

struct SummaryCardView: View {
    var income: Double
    var expense: Double
    var percentChange: Double?
    
    private var netIncome: Double {
        income - expense
    }
    
    var body: some View {
        VStack(spacing: Spacing.medium) {
            // 總體收支狀況
            HStack {
                VStack(alignment: .leading) {
                    Text("本月總收入")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("£\(String(format: "%.2f", income))")
                        .font(.monoLarge)
                        .foregroundColor(.accentGreen)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("本月總支出")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("£\(String(format: "%.2f", expense))")
                        .font(.monoLarge)
                        .foregroundColor(.expenseOrange)
                }
            }
            
            Divider()
            
            // 收支差額
            VStack(alignment: .leading, spacing: 4) {
                Text("凈收入")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .lastTextBaseline) {
                    Text("£\(String(format: "%.2f", netIncome))")
                        .font(.monoLarge)
                        .foregroundColor(netIncome >= 0 ? .accentGreen : .red)
                    
                    if let percentChange = percentChange {
                        Text("\(percentChange >= 0 ? "+" : "")\(String(format: "%.1f", percentChange))%")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(percentChange >= 0 ? Color.accentGreen.opacity(0.2) : Color.red.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(percentChange >= 0 ? .accentGreen : .red)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.large)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 10)
    }
}

struct MetricCardView: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: Spacing.small) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, Spacing.small)
            
            Text(value)
                .font(.monoMedium)
                .foregroundColor(color)
                .padding(.vertical, 4)
            
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                )
                .padding(.bottom, Spacing.small)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct SimpleBarChart: View {
    var data: [Double]
    var labels: [String]
    var barColor: Color = .accentGreen
    var backgroundBarColor: Color = Color.lightGray
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<min(data.count, labels.count), id: \.self) { index in
                    VStack {
                        ZStack(alignment: .bottom) {
                            // 背景柱
                            RoundedRectangle(cornerRadius: 4)
                                .fill(backgroundBarColor)
                                .frame(height: 100)
                            
                            // 數據柱
                            if data[index] > 0 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(barColor)
                                    .frame(height: CGFloat(data[index]) * 100 / maxValue())
                            }
                        }
                        .frame(width: 24)
                        
                        Text(labels[index])
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
        }
    }
    
    private func maxValue() -> CGFloat {
        if let max = data.max(), max > 0 {
            return CGFloat(max)
        }
        return 100 // 默認高度
    }
}

struct ChartCardView: View {
    var title: String = "收支趨勢"
    var period: String = "本月"
    var incomeData: [Double]
    var expenseData: [Double]
    var labels: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            // 標題
            HStack {
                Text(title)
                    .font(.titleMedium)
                
                Spacer()
                
                Text(period)
                    .font(.caption)
                    .foregroundColor(.primaryBlue)
            }
            
            // 圖表
            ZStack {
                SimpleBarChart(data: expenseData, labels: labels, barColor: .expenseOrange)
                SimpleBarChart(data: incomeData, labels: labels, barColor: .accentGreen)
            }
            .padding(.top, Spacing.small)
            
            // 圖例
            HStack {
                HStack {
                    Circle()
                        .fill(Color.accentGreen)
                        .frame(width: 8, height: 8)
                    
                    Text("收入")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                    .frame(width: 20)
                
                HStack {
                    Circle()
                        .fill(Color.expenseOrange)
                        .frame(width: 8, height: 8)
                    
                    Text("支出")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.large)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct DashboardComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                SummaryCardView(
                    income: 2560.50,
                    expense: 1180.75,
                    percentChange: 12.5
                )
                
                HStack(spacing: 16) {
                    MetricCardView(
                        title: "平均時薪",
                        value: "£18.50",
                        icon: "sterling.circle.fill",
                        color: .primaryBlue
                    )
                    
                    MetricCardView(
                        title: "每英里成本",
                        value: "£0.42",
                        icon: "fuelpump.fill",
                        color: .expenseOrange
                    )
                }
                
                ChartCardView(
                    title: "收支趨勢",
                    period: "本週",
                    incomeData: [65, 75, 85, 90, 65, 45, 75],
                    expenseData: [45, 55, 65, 50, 55, 35, 55],
                    labels: ["一", "二", "三", "四", "五", "六", "日"]
                )
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}
