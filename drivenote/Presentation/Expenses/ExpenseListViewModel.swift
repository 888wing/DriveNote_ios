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
    private let expenseRepository: ExpenseRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(getExpensesUseCase: GetExpensesUseCase, deleteExpenseUseCase: DeleteExpenseUseCase, expenseRepository: ExpenseRepository) {
        self.getExpensesUseCase = getExpensesUseCase
        self.deleteExpenseUseCase = deleteExpenseUseCase
        self.expenseRepository = expenseRepository
        
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
        print("ExpenseListViewModel: 開始加載支出數據")
        isLoading = true
        error = nil
        
        // 設置超時計時器
        let timeoutSeconds = 10.0
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeoutSeconds, repeats: false) { [weak self] _ in
            if self?.isLoading == true {
                print("ExpenseListViewModel: 加載超時")
                self?.isLoading = false
                self?.error = NSError(domain: "com.drivenote", code: -1, userInfo: [NSLocalizedDescriptionKey: "加載超時，請重試"])
            }
        }
        
        getExpensesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    timeoutTimer.invalidate() // 取消超時計時器
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("ExpenseListViewModel: 加載失敗 - \(error.localizedDescription)")
                        self?.error = error
                    } else {
                        print("ExpenseListViewModel: 加載完成")
                    }
                },
                receiveValue: { [weak self] expenses in
                    timeoutTimer.invalidate() // 取消超時計時器
                    print("ExpenseListViewModel: 收到 \(expenses.count) 條支出記錄")
                    self?.updateExpenses(expenses)
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateExpenses(_ expenses: [Expense]) {
        if expenses.isEmpty {
            insertFakeExpense()
        } else {
            let expenseViewModels = expenses.map { ExpenseItemViewModel(expense: $0) }
            self.expenses = expenseViewModels
            applyFilters()
        }
    }
    
    /// 僅供開發測試：自動插入一筆假資料到 Core Data
    private func insertFakeExpense() {
        print("ExpenseListViewModel: 插入測試數據")
        let fakeExpense = Expense(
            id: UUID(),
            date: Date(),
            amount: 123.45,
            category: .fuel,
            description: "測試假資料",
            isTaxDeductible: true,
            taxDeductiblePercentage: 100,
            creationMethod: .manual,
            isUploaded: false,
            lastModified: Date()
        )
        
        print("ExpenseListViewModel: 準備保存測試數據")
        expenseRepository.saveExpense(expense: fakeExpense)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("ExpenseListViewModel: 保存測試數據失敗 - \(error.localizedDescription)")
                    } else {
                        print("ExpenseListViewModel: 保存測試數據成功，重新加載")
                        self?.loadExpenses()
                    }
                }, 
                receiveValue: { savedExpense in
                    print("ExpenseListViewModel: 測試數據已保存 ID=\(savedExpense.id)")
                }
            )
            .store(in: &cancellables)
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
