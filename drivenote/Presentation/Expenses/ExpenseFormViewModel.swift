import Foundation
import Combine
import UIKit

class ExpenseFormViewModel: ObservableObject {
    // Form state
    @Published var date: Date = Date()
    @Published var amount: Double?
    @Published var amountString: String = ""
    @Published var category: ExpenseCategory = .fuel
    @Published var description: String = ""
    @Published var isTaxDeductible: Bool = true
    @Published var taxDeductiblePercentage: Int = 100
    @Published var receiptImage: UIImage?
    
    // Form validation
    @Published var amountError: String?
    @Published var formIsValid: Bool = false
    
    // Process state
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var formCompleted: Bool = false
    @Published var formStep: Int = 1
    
    // Edit mode state
    private var expense: Expense?
    var isEditMode: Bool { expense != nil }
    
    // Dependencies
    private let saveExpenseUseCase: SaveExpenseUseCase
    private let getReceiptImageUseCase: GetReceiptImageUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(expense: Expense? = nil, 
         saveExpenseUseCase: SaveExpenseUseCase,
         getReceiptImageUseCase: GetReceiptImageUseCase) {
        self.expense = expense
        self.saveExpenseUseCase = saveExpenseUseCase
        self.getReceiptImageUseCase = getReceiptImageUseCase
        
        // If in edit mode, populate form with existing data
        if let expense = expense {
            self.date = expense.date
            self.amount = expense.amount
            self.amountString = String(format: "%.2f", expense.amount)
            self.category = expense.category
            self.description = expense.description ?? ""
            self.isTaxDeductible = expense.isTaxDeductible
            self.taxDeductiblePercentage = expense.taxDeductiblePercentage
            
            // Attempt to load receipt image if available
            if let receiptIds = expense.receiptIds, let firstReceiptId = receiptIds.first {
                loadReceiptImage(receiptId: firstReceiptId)
            }
        }
        
        // Set up form validation
        setupValidation()
    }
    
    private func setupValidation() {
        // Validate amount when changed
        $amountString
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validateAmount(value)
            }
            .store(in: &cancellables)
        
        // Update form validity
        Publishers.CombineLatest($amount, $description)
            .map { amount, description in
                return amount != nil && amount! > 0
            }
            .assign(to: &$formIsValid)
    }
    
    private func validateAmount(_ value: String) {
        // Clear previous error
        amountError = nil
        
        // Empty is allowed (for now)
        if value.isEmpty {
            amount = nil
            return
        }
        
        // Try to parse as number
        if let parsedAmount = Double(value) {
            if parsedAmount <= 0 {
                amountError = "金額必須大於零"
                amount = nil
            } else {
                amount = parsedAmount
            }
        } else {
            amountError = "請輸入有效的金額"
            amount = nil
        }
    }
    
    private func loadReceiptImage(receiptId: UUID) {
        // This is a simplified implementation - in a real app, we would need to create
        // a temporary Receipt object to pass to the use case
        let dummyReceipt = Receipt(id: receiptId, filePath: "")
        
        getReceiptImageUseCase.execute(receipt: dummyReceipt)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] image in
                    self?.receiptImage = image
                }
            )
            .store(in: &cancellables)
    }
    
    func saveExpense(completion: @escaping () -> Void) {
        guard formIsValid else { return }
        
        isLoading = true
        error = nil
        
        // Create or update expense object
        let expenseToSave = Expense(
            id: expense?.id ?? UUID(),
            date: date,
            amount: amount ?? 0,
            category: category,
            description: description.isEmpty ? nil : description,
            isTaxDeductible: isTaxDeductible,
            taxDeductiblePercentage: taxDeductiblePercentage,
            creationMethod: .manual,
            isUploaded: false,
            lastModified: Date(),
            receiptIds: expense?.receiptIds, // Preserve existing receipt associations
            relatedMileageId: expense?.relatedMileageId // Preserve existing mileage association
        )
        
        saveExpenseUseCase.execute(expense: expenseToSave)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionResult in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completionResult {
                        self?.error = error
                    } else {
                        self?.formCompleted = true
                        completion()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func nextStep() {
        if formStep < 3 {
            formStep += 1
        }
    }
    
    func previousStep() {
        if formStep > 1 {
            formStep -= 1
        }
    }
    
    func getTaxTipForCategory() -> String? {
        return category.taxTip
    }
    
    // Helper for formatted title
    var formTitle: String {
        return isEditMode ? "編輯支出" : "添加支出"
    }
    
    // Helper for step title
    func getStepTitle() -> String {
        switch formStep {
        case 1:
            return "基本信息"
        case 2:
            return "詳細資料"
        case 3:
            return "稅務信息"
        default:
            return ""
        }
    }
}
