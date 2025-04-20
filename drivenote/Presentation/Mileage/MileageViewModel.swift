import Foundation
import Combine

class MileageViewModel: StatefulViewModel<[Mileage]> {
    // 統計數據
    @Published var totalMileage: Double = 0
    @Published var taxDeductibleMileage: Double = 0
    @Published var averageDailyMileage: Double = 0
    @Published var totalTrips: Int = 0
    
    // 里程數據
    @Published var mileages: [Mileage] = []
    @Published var selectedPeriod: Period = .month
    
    // 依賴
    private let repository: MileageRepository
    
    init(repository: MileageRepository) {
        self.repository = repository
        super.init()
        loadMileages()
    }
    
    func loadMileages() {
        setLoading()
        
        repository.getAllMileage()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("MileageViewModel: 加載失敗 - \(error.localizedDescription)")
                        self?.setError(error)
                    }
                },
                receiveValue: { [weak self] mileages in
                    guard let self = self else { return }
                    
                    self.mileages = mileages
                    
                    if mileages.isEmpty {
                        self.setEmpty()
                    } else {
                        self.calculateStatistics(mileages)
                        self.setLoaded(mileages)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func calculateStatistics(_ mileages: [Mileage]) {
        // 計算總里程
        totalMileage = mileages.reduce(0) { $0 + $1.distance }
        
        // 計算可抵稅里程
        taxDeductibleMileage = mileages
            .filter { $0.isTaxDeductible }
            .reduce(0) { $0 + ($1.distance * Double($1.taxDeductiblePercentage) / 100.0) }
        
        // 設置總行程數
        totalTrips = mileages.count
        
        // 計算平均每日里程
        if let oldestDate = mileages.map({ $0.date }).min(),
           let newestDate = mileages.map({ $0.date }).max() {
            let days = max(1, Calendar.current.dateComponents([.day], from: oldestDate, to: newestDate).day ?? 1)
            averageDailyMileage = totalMileage / Double(days)
        } else {
            averageDailyMileage = totalMileage
        }
    }
    
    func deleteMileage(_ mileage: Mileage) {
        repository.deleteMileage(id: mileage.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error, source: .coreData, isUserVisible: true)
                    }
                },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    
                    // 從列表中移除
                    if let index = self.mileages.firstIndex(where: { $0.id == mileage.id }) {
                        self.mileages.remove(at: index)
                    }
                    
                    // 重新加載數據以更新統計信息
                    self.loadMileages()
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteMileage(at offsets: IndexSet) {
        for index in offsets {
            let mileage = mileages[index]
            deleteMileage(mileage)
        }
    }
    
    // MARK: - 過濾方法
    
    func filterMileagesByPeriod(_ period: Period) {
        selectedPeriod = period
        loadMileagesByPeriod(period)
    }
    
    private func loadMileagesByPeriod(_ period: Period) {
        setLoading()
        
        let (startDate, endDate) = period.dateRange()
        
        repository.getMileageByDateRange(start: startDate, end: endDate)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.setError(error)
                    }
                },
                receiveValue: { [weak self] mileages in
                    guard let self = self else { return }
                    
                    self.mileages = mileages
                    
                    if mileages.isEmpty {
                        self.setEmpty()
                    } else {
                        self.calculateStatistics(mileages)
                        self.setLoaded(mileages)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - 錯誤處理
    
    override func canRecoverFromError(_ error: Error) -> Bool {
        // 某些錯誤類型可以通過重試來恢復
        if let nsError = error as NSError? {
            return nsError.domain == NSURLErrorDomain || 
                   nsError.domain == NSCocoaErrorDomain
        }
        return false
    }
    
    override func attemptRecovery(from error: Error) {
        // 重新加載數據
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.loadMileages()
        }
    }
}
