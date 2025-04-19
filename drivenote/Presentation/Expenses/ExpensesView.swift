import SwiftUI

struct ExpensesView: View {
    @StateObject private var viewModel = DIContainer.shared.makeExpenseListViewModel()
    @State private var showingAddExpense = false
    @State private var showingFilterSheet = false
    @State private var editingExpense: ExpenseItemViewModel?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $viewModel.searchText, placeholder: "搜索支出...")
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Category filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryFilterChip(
                            title: "所有",
                            isSelected: viewModel.filterCategory == nil,
                            action: { viewModel.setFilter(category: nil) }
                        )
                        
                        ForEach(ExpenseCategory.allCases) { category in
                            CategoryFilterChip(
                                title: category.displayName,
                                icon: category.icon,
                                isSelected: viewModel.filterCategory == category,
                                action: { viewModel.setFilter(category: category) }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Total amount display
                HStack {
                    if viewModel.hasFiltersApplied {
                        Button(action: {
                            viewModel.clearFilters()
                        }) {
                            Label("清除篩選", systemImage: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    
                    Spacer()
                    
                    Text("總計: \(viewModel.formattedTotalExpense)")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.trailing)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Divider
                Divider()
                
                if viewModel.isLoading && viewModel.expenses.isEmpty {
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
                            viewModel.loadExpenses()
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredExpenses.isEmpty {
                    // Empty State
                    VStack(spacing: Spacing.medium) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.primaryBlue)
                        
                        if viewModel.hasFiltersApplied {
                            Text("無符合條件的支出記錄")
                                .font(.headline)
                            
                            Button(action: {
                                viewModel.clearFilters()
                            }) {
                                Text("清除篩選")
                                    .padding(.horizontal, Spacing.medium)
                                    .padding(.vertical, Spacing.small)
                                    .background(Color.primaryBlue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, Spacing.small)
                        } else {
                            Text("尚未添加任何支出記錄")
                                .font(.headline)
                            
                            Button(action: {
                                showingAddExpense = true
                            }) {
                                Text("添加支出")
                                    .padding(.horizontal, Spacing.medium)
                                    .padding(.vertical, Spacing.small)
                                    .background(Color.primaryBlue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, Spacing.small)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Expense List
                    List {
                        ForEach(viewModel.sortedMonthKeys, id: \.self) { monthKey in
                            Section(header: Text(monthKey)) {
                                ForEach(viewModel.expensesByMonth[monthKey] ?? []) { expense in
                                    ExpenseRow(expense: expense)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            editingExpense = expense
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                viewModel.deleteExpense(expense.id)
                                            } label: {
                                                Label("刪除", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        viewModel.loadExpenses()
                    }
                }
            }
            .navigationTitle("支出")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                ExpenseFormView()
                    .onDisappear {
                        // Refresh list when form is dismissed
                        viewModel.loadExpenses()
                    }
            }
            .sheet(item: $editingExpense) { expense in
                // Convert view model back to domain model for editing
                let domainExpense = Expense(
                    id: expense.id,
                    date: expense.date,
                    amount: expense.amount,
                    category: expense.category,
                    description: expense.description,
                    isTaxDeductible: expense.isTaxDeductible,
                    taxDeductiblePercentage: expense.taxDeductiblePercentage
                )
                
                ExpenseFormView(expense: domainExpense)
                    .onDisappear {
                        // Refresh list when form is dismissed
                        viewModel.loadExpenses()
                    }
            }
        }
    }
}

// MARK: - Supporting Views

struct ExpenseRow: View {
    let expense: ExpenseItemViewModel
    
    var body: some View {
        HStack {
            // Category Icon
            Image(systemName: expense.category.icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(getCategoryColor(expense.category))
                .cornerRadius(8)
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.body)
                    .lineLimit(1)
                
                HStack {
                    Text(expense.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if expense.isTaxDeductible {
                        Text(expense.formattedTaxDeductible)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentGreen.opacity(0.2))
                            .foregroundColor(.accentGreen)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            // Amount
            Text(expense.formattedAmount)
                .font(.headline)
                .foregroundColor(.expenseOrange)
        }
    }
    
    private func getCategoryColor(_ category: ExpenseCategory) -> Color {
        switch category {
        case .fuel:
            return .expenseOrange
        case .insurance:
            return .primaryBlue
        case .maintenance:
            return .purple
        case .tax:
            return .green
        case .license:
            return .deepBlue
        case .parking:
            return .red
        case .toll:
            return .teal
        case .cleaning:
            return .pink
        case .other:
            return .gray
        }
    }
}

struct CategoryFilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primaryBlue : Color.lightGray.opacity(0.5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    ExpensesView()
}
