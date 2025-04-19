import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DIContainer.shared.makeDashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Period Selector
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
                    
                    if viewModel.isLoading {
                        // Loading State
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding(.top, 100)
                    } else if let error = viewModel.error {
                        // Error State
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
                            
                            Button(action: {
                                viewModel.loadDashboardData()
                            }) {
                                Text("重試")
                                    .padding(.horizontal, Spacing.medium)
                                    .padding(.vertical, Spacing.small)
                                    .background(Color.primaryBlue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, Spacing.small)
                        }
                        .padding()
                        .frame(minHeight: 300)
                    } else {
                        // Content
                        VStack(spacing: Spacing.large) {
                            // Income/Expense Summary Card
                            SummaryCardView(
                                income: viewModel.totalIncome,
                                expense: viewModel.totalExpense,
                                percentChange: viewModel.netIncomeChangePercent
                            )
                            .padding(.horizontal)
                            
                            // Key Metrics
                            HStack(spacing: Spacing.medium) {
                                // Hourly Rate
                                MetricCardView(
                                    title: "平均時薪",
                                    value: viewModel.formattedHourlyRate,
                                    icon: "sterling.circle.fill",
                                    color: .accentGreen
                                )
                                
                                // Cost Per Mile
                                MetricCardView(
                                    title: "每英里成本",
                                    value: viewModel.formattedCostPerMile,
                                    icon: "fuelpump.fill",
                                    color: .expenseOrange
                                )
                            }
                            .padding(.horizontal)
                            
                            // Chart
                            ChartCardView(
                                title: "收支趨勢",
                                period: viewModel.selectedPeriod.displayName,
                                incomeData: viewModel.incomeData,
                                expenseData: viewModel.expenseData,
                                labels: viewModel.chartLabels
                            )
                            .padding(.horizontal)
                            
                            // Tax Summary
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
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("儀表板")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.loadDashboardData()
            }
        }
    }
}

#Preview {
    DashboardView()
}
