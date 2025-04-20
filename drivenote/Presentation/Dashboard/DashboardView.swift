import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DIContainer.shared.makeDashboardViewModel()
    // 添加一個狀態變量追蹤加載狀態，用於動畫
    @State private var isLoading = false 
    
    var body: some View {

        // 監聽狀態變化來更新加載標誌
        if case .loading = viewModel.state {
            DispatchQueue.main.async {
                isLoading = true
            }
        } else {
            DispatchQueue.main.async {
                isLoading = false
            }
        }
        
        return NavigationView {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // 期間選擇器
                    Picker("期間", selection: $viewModel.selectedPeriod) {
                        ForEach(Period.allCases) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .onChange(of: viewModel.selectedPeriod) { _ in
                        viewModel.loadDashboardData()
                    }
                    
                    // 使用視圖狀態處理組件顯示內容
                    ViewStateHandler(state: viewModel.state) { data in
                        dashboardContent
                    }
                    .loading {
                        VStack(spacing: Spacing.large) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding(.top, 100)
                            
                            Text("正在加載儀表板數據...")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(minHeight: 300)
                    }
                    .empty {
                        VStack(spacing: Spacing.large) {
                            Image(systemName: "square.stack.3d.up.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("暫無數據")
                                .font(.headline)
                            
                            Text("添加您的第一筆支出、收入或里程記錄來查看儀表板")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            Button(action: {
                                viewModel.loadDashboardData()
                            }) {
                                Text("重新加載")
                                    .padding(.horizontal, Spacing.medium)
                                    .padding(.vertical, Spacing.small)
                                    .background(Color.primaryBlue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.top)
                        }
                        .padding()
                        .frame(minHeight: 300)
                    }
                    .error { error, retry in
                        VStack(spacing: Spacing.medium) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.expenseOrange)
                            
                            Text("加載數據時出現錯誤")
                                .font(.headline)
                            
                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: retry) {
                                Text("重試")
                                    .padding(.horizontal, Spacing.medium)
                                    .padding(.vertical, Spacing.small)
                                    .background(Color.primaryBlue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.top, Spacing.small)
                        }
                        .padding()
                        .frame(minHeight: 300)
                    }
                    .onRetry {
                        viewModel.loadDashboardData()
                    }
                }
                .padding(.vertical)
                // 使用本地狀態變量來觸發動畫
                .animation(.easeInOut, value: isLoading) 
            }
            .navigationTitle("儀表板")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.loadDashboardData()
            }
            .onAppear {
                // 更新加載狀態並加載數據
                if case .loading = viewModel.state {
                    isLoading = true
                    viewModel.loadDashboardData()
                }
            }
        }
    }
    
    // 儀表板主要內容
    private var dashboardContent: some View {
        VStack(spacing: Spacing.large) {
            // 收支摘要卡片
            SummaryCardView(
                income: viewModel.totalIncome,
                expense: viewModel.totalExpense,
                percentChange: viewModel.netIncomeChangePercent
            )
            .padding(.horizontal)
            .transition(.opacity)
            
            // 關鍵指標
            HStack(spacing: Spacing.medium) {
                // 時薪
                MetricCardView(
                    title: "平均時薪",
                    value: viewModel.formattedHourlyRate,
                    icon: "sterling.circle.fill",
                    color: .accentGreen
                )
                
                // 每英里成本
                MetricCardView(
                    title: "每英里成本",
                    value: viewModel.formattedCostPerMile,
                    icon: "fuelpump.fill",
                    color: .expenseOrange
                )
            }
            .padding(.horizontal)
            .transition(.opacity)
            
            // 圖表
            ChartCardView(
                title: "收支趨勢",
                period: viewModel.selectedPeriod.displayName,
                incomeData: viewModel.incomeData,
                expenseData: viewModel.expenseData,
                labels: viewModel.chartLabels
            )
            .padding(.horizontal)
            .transition(.opacity)
            
            // 稅務摘要
            ModernCard(title: "稅務摘要", icon: "percent", tint: .primaryBlue) {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    HStack {
                        Text("可抵稅支出總額")
                            .font(.body)
                        
                        Spacer()
                        
                        Text(viewModel.formattedTotalTaxDeductible)
                            .font(.title3)
                            .foregroundColor(.accentGreen)
                    }
                    
                    HStack {
                        Text("總工時")
                            .font(.body)
                        
                        Spacer()
                        
                        Text(viewModel.formattedTotalWorkHours)
                            .font(.title3)
                    }
                    
                    HStack {
                        Text("總里程")
                            .font(.body)
                        
                        Spacer()
                        
                        Text(viewModel.formattedTotalMileage)
                            .font(.title3)
                    }
                }
            }
            .padding(.horizontal)
            .transition(.opacity)
        }
    }
}

// 使用我們在 GradientButton.swift 中已定義的 ScaleButtonStyle

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
