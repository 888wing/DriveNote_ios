import Foundation
import Combine

/// Dependency Injection Container class that provides all required dependencies
class DIContainer {
    static let shared = DIContainer()
    
    private init() {
        // Private initializer to ensure singleton pattern
    }
    
    // MARK: - Repositories
    
    // Expense Repository
    lazy var expenseRepository: ExpenseRepository = {
        let localRepo = CoreDataExpenseRepository()
        return ExpenseRepositoryImpl(localRepository: localRepo)
    }()
    
    // Mileage Repository
    lazy var mileageRepository: MileageRepository = {
        let localRepo = CoreDataMileageRepository()
        return MileageRepositoryImpl(localRepository: localRepo)
    }()
    
    // WorkHours Repository
    lazy var workHoursRepository: WorkHoursRepository = {
        let localRepo = CoreDataWorkHoursRepository()
        return WorkHoursRepositoryImpl(localRepository: localRepo)
    }()
    
    // Receipt Repository
    lazy var receiptRepository: ReceiptRepository = {
        let localRepo = CoreDataReceiptRepository()
        return ReceiptRepositoryImpl(localRepository: localRepo)
    }()
    
    // Income Repository
    lazy var incomeRepository: IncomeRepository = {
        let localRepo = CoreDataIncomeRepository()
        return IncomeRepositoryImpl(localRepository: localRepo)
    }()
    
    // MARK: - Use Cases
    
    // Expense Use Cases
    lazy var saveExpenseUseCase: SaveExpenseUseCase = {
        return SaveExpenseUseCase(repository: expenseRepository)
    }()
    
    lazy var getExpensesUseCase: GetExpensesUseCase = {
        return GetExpensesUseCase(repository: expenseRepository)
    }()
    
    lazy var getExpenseDetailsUseCase: GetExpenseDetailsUseCase = {
        return GetExpenseDetailsUseCase(expenseRepository: expenseRepository, receiptRepository: receiptRepository)
    }()
    
    lazy var deleteExpenseUseCase: DeleteExpenseUseCase = {
        return DeleteExpenseUseCase(repository: expenseRepository)
    }()
    
    lazy var analyzeExpensesUseCase: AnalyzeExpensesUseCase = {
        return AnalyzeExpensesUseCase(repository: expenseRepository)
    }()
    
    // Mileage Use Cases
    lazy var saveMileageUseCase: SaveMileageUseCase = {
        return SaveMileageUseCase(repository: mileageRepository)
    }()
    
    lazy var getMileageUseCase: GetMileageUseCase = {
        return GetMileageUseCase(repository: mileageRepository)
    }()
    
    lazy var getMileageDetailsUseCase: GetMileageDetailsUseCase = {
        return GetMileageDetailsUseCase(mileageRepository: mileageRepository, expenseRepository: expenseRepository)
    }()
    
    lazy var deleteMileageUseCase: DeleteMileageUseCase = {
        return DeleteMileageUseCase(repository: mileageRepository)
    }()
    
    lazy var calculateMileageCostUseCase: CalculateMileageCostUseCase = {
        return CalculateMileageCostUseCase(mileageRepository: mileageRepository, expenseRepository: expenseRepository)
    }()
    
    // WorkHours Use Cases
    lazy var saveWorkHoursUseCase: SaveWorkHoursUseCase = {
        return SaveWorkHoursUseCase(repository: workHoursRepository)
    }()
    
    lazy var getWorkHoursUseCase: GetWorkHoursUseCase = {
        return GetWorkHoursUseCase(repository: workHoursRepository)
    }()
    
    lazy var getTodayWorkHoursUseCase: GetTodayWorkHoursUseCase = {
        return GetTodayWorkHoursUseCase(repository: workHoursRepository)
    }()
    
    lazy var deleteWorkHoursUseCase: DeleteWorkHoursUseCase = {
        return DeleteWorkHoursUseCase(repository: workHoursRepository)
    }()
    
    lazy var calculateHourlyRateUseCase: CalculateHourlyRateUseCase = {
        return CalculateHourlyRateUseCase(workHoursRepository: workHoursRepository, incomeRepository: incomeRepository)
    }()
    
    // Receipt Use Cases
    lazy var saveReceiptUseCase: SaveReceiptUseCase = {
        return SaveReceiptUseCase(repository: receiptRepository)
    }()
    
    lazy var processReceiptOCRUseCase: ProcessReceiptOCRUseCase = {
        return ProcessReceiptOCRUseCase(repository: receiptRepository)
    }()
    
    lazy var convertOCRToExpenseUseCase: ConvertOCRToExpenseUseCase = {
        return ConvertOCRToExpenseUseCase(receiptRepository: receiptRepository, expenseRepository: expenseRepository)
    }()
    
    lazy var getReceiptImageUseCase: GetReceiptImageUseCase = {
        return GetReceiptImageUseCase(repository: receiptRepository)
    }()
    
    lazy var deleteReceiptUseCase: DeleteReceiptUseCase = {
        return DeleteReceiptUseCase(repository: receiptRepository)
    }()
    
    // Dashboard Use Case
    lazy var getDashboardDataUseCase: GetDashboardDataUseCase = {
        return GetDashboardDataUseCase(
            expenseRepository: expenseRepository,
            incomeRepository: incomeRepository,
            mileageRepository: mileageRepository,
            workHoursRepository: workHoursRepository
        )
    }()
    
    // MARK: - View Models Factory Methods
    
    // These factory methods will be implemented as we create the view models
    func makeDashboardViewModel() -> DashboardViewModel {
        return DashboardViewModel(getDashboardDataUseCase: getDashboardDataUseCase)
    }
    
    func makeExpenseListViewModel() -> ExpenseListViewModel {
        return ExpenseListViewModel(
            getExpensesUseCase: getExpensesUseCase, 
            deleteExpenseUseCase: deleteExpenseUseCase,
            expenseRepository: expenseRepository
        )
    }
    
    func makeExpenseFormViewModel(expense: Expense? = nil) -> ExpenseFormViewModel {
        return ExpenseFormViewModel(
            expense: expense,
            saveExpenseUseCase: saveExpenseUseCase,
            getReceiptImageUseCase: getReceiptImageUseCase
        )
    }
    
    // 以下 ViewModel 工廠方法將在實現對應功能時解除註釋
    
    /*
    func makeMileageListViewModel() -> MileageListViewModel {
        return MileageListViewModel(getMileageUseCase: getMileageUseCase, deleteMileageUseCase: deleteMileageUseCase)
    }
    
    func makeMileageFormViewModel(mileage: Mileage? = nil) -> MileageFormViewModel {
        return MileageFormViewModel(
            mileage: mileage,
            saveMileageUseCase: saveMileageUseCase
        )
    }
    
    func makeWorkHoursListViewModel() -> WorkHoursListViewModel {
        return WorkHoursListViewModel(
            getWorkHoursUseCase: getWorkHoursUseCase,
            deleteWorkHoursUseCase: deleteWorkHoursUseCase,
            calculateHourlyRateUseCase: calculateHourlyRateUseCase
        )
    }
    
    func makeWorkHoursFormViewModel(workHours: WorkHours? = nil) -> WorkHoursFormViewModel {
        return WorkHoursFormViewModel(
            workHours: workHours,
            saveWorkHoursUseCase: saveWorkHoursUseCase,
            getTodayWorkHoursUseCase: getTodayWorkHoursUseCase
        )
    }
    */
}
