import Foundation
import Combine

class ExpenseListViewModel: ObservableObject {
    // Published properties for UI
    @Published var expenses: [ExpenseItemViewModel] = []
    @Published var filteredExpenses: [ExpenseItemViewModel] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var filterCategory: ExpenseCategory?
    @Published var searchText: String = ""
    
    // Dependencies
    private let getExpensesUseCase: GetExpensesUseCase
    private let deleteExpenseUseCase: DeleteExpenseUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(getExpensesUseCase: GetExpensesUseCase, deleteExpenseUseCase: DeleteExpenseUseCase) {
        self.getExpensesUseCase = getExpensesUseCase
        self.deleteExpenseUseCase = deleteExpenseUseCase
        
        // Monitor search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        // Load data when initialized
        loadExpenses()
    }
    
    func loadExpenses() {
        isLoading = true
        error = nil
        
        getExpensesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] expenses in
                    self?.updateExpenses(expenses)
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateExpenses(_ expenses: [Expense]) {
        let expenseViewModels = expenses.map { ExpenseItemViewModel(expense: $0) }
        self.expenses = expenseViewModels
        applyFilters()
    }
    
    func deleteExpense(_ id: UUID) {
        isLoading = true
        
        deleteExpenseUseCase.execute(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.error = error
                    } else {
                        // Remove from local list on success
                        self?.expenses.removeAll { $0.id == id }
                        self?.applyFilters()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func applyFilters() {
        var result = expenses
        
        // Apply category filter
        if let category = filterCategory {
            result = result.filter { $0.category == category }
        }
        
        // Apply search filter if not empty
        if !searchText.isEmpty {
            result = result.filter { expense in
                return expense.description.localizedCaseInsensitiveContains(searchText) ||
                       expense.category.displayName.localizedCaseInsensitiveContains(searchText) ||
                       expense.formattedAmount.localizedCaseInsensitiveContains(searchText) ||
                       expense.formattedDate.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredExpenses = result
    }
    
    func clearFilters() {
        filterCategory = nil
        searchText = ""
        applyFilters()
    }
    
    func setFilter(category: ExpenseCategory?) {
        filterCategory = category
        applyFilters()
    }
    
    // Calculated properties for UI display
    var totalExpenseAmount: Double {
        return filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var formattedTotalExpense: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "£"
        
        return formatter.string(from: NSNumber(value: totalExpenseAmount)) ?? "£0.00"
    }
    
    var hasFiltersApplied: Bool {
        return filterCategory != nil || !searchText.isEmpty
    }
    
    // Group expenses by month
    var expensesByMonth: [String: [ExpenseItemViewModel]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        
        var result = [String: [ExpenseItemViewModel]]()
        
        for expense in filteredExpenses {
            let monthKey = formatter.string(from: expense.date)
            
            if result[monthKey] == nil {
                result[monthKey] = [expense]
            } else {
                result[monthKey]?.append(expense)
            }
        }
        
        return result
    }
    
    // Get sorted month keys for display
    var sortedMonthKeys: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        
        let sortedKeys = expensesByMonth.keys.sorted { key1, key2 in
            guard let date1 = formatter.date(from: key1),
                  let date2 = formatter.date(from: key2) else {
                return key1 > key2
            }
            return date1 > date2
        }
        
        return sortedKeys
    }
}

// View model for individual expense items
struct ExpenseItemViewModel: Identifiable {
    let id: UUID
    let date: Date
    let amount: Double
    let category: ExpenseCategory
    let description: String
    let isTaxDeductible: Bool
    let taxDeductiblePercentage: Int
    
    // Derived properties for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "£"
        
        return formatter.string(from: NSNumber(value: amount)) ?? "£0.00"
    }
    
    var taxDeductibleAmount: Double {
        if isTaxDeductible {
            return amount * Double(taxDeductiblePercentage) / 100.0
        }
        return 0.0
    }
    
    var formattedTaxDeductible: String {
        if !isTaxDeductible {
            return "不可抵稅"
        }
        
        if taxDeductiblePercentage >= 100 {
            return "完全可抵稅"
        }
        
        return "\(taxDeductiblePercentage)% 可抵稅"
    }
    
    // Initialize from domain model
    init(expense: Expense) {
        id = expense.id
        date = expense.date
        amount = expense.amount
        category = expense.category
        description = expense.description ?? expense.category.displayName
        isTaxDeductible = expense.isTaxDeductible
        taxDeductiblePercentage = expense.taxDeductiblePercentage
    }
}
