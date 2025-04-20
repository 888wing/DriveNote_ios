import Foundation
import Combine

class MileageFormViewModel: BaseViewModel {
    // 表單數據
    @Published var date: Date = Date()
    @Published var startMileage: Double? = nil
    @Published var endMileage: Double? = nil
    @Published var distance: Double? = nil
    @Published var purpose: String = ""
    @Published var isTaxDeductible: Bool = true
    @Published var taxDeductiblePercentage: Int = 100
    
    // 表單狀態
    @Published var isEditing: Bool = false
    @Published var isSaving: Bool = false
    @Published var formError: String? = nil
    @Published var useDirectDistance: Bool = false
    
    // 依賴和引用
    private let repository: MileageRepository
    private var editingMileage: Mileage?
    
    var isValid: Bool {
        if useDirectDistance {
            return distance != nil && distance! > 0 && !purpose.isEmpty
        } else {
            return startMileage != nil && endMileage != nil && 
                endMileage! > startMileage! && !purpose.isEmpty
        }
    }
    
    init(repository: MileageRepository, mileage: Mileage? = nil) {
        self.repository = repository
        super.init()
        
        if let mileage = mileage {
            setupForEditing(mileage)
        }
    }
    
    private func setupForEditing(_ mileage: Mileage) {
        editingMileage = mileage
        isEditing = true
        
        // 設置表單數據
        date = mileage.date
        
        if let start = mileage.startMileage, let end = mileage.endMileage {
            startMileage = start
            endMileage = end
            useDirectDistance = false
        } else {
            distance = mileage.distance
            useDirectDistance = true
        }
        
        purpose = mileage.purpose ?? ""
        isTaxDeductible = mileage.isTaxDeductible
        taxDeductiblePercentage = mileage.taxDeductiblePercentage
    }
    
    func save(completion: @escaping (Bool) -> Void) {
        guard isValid else {
            formError = "請填寫必要的信息"
            completion(false)
            return
        }
        
        isSaving = true
        formError = nil
        
        // 計算距離
        let finalDistance: Double
        if useDirectDistance {
            finalDistance = distance ?? 0
        } else {
            finalDistance = (endMileage ?? 0) - (startMileage ?? 0)
        }
        
        // 創建或更新里程記錄
        let mileage = Mileage(
            id: editingMileage?.id ?? UUID(),
            date: date,
            startMileage: useDirectDistance ? nil : startMileage,
            endMileage: useDirectDistance ? nil : endMileage,
            distance: finalDistance,
            purpose: purpose,
            isUploaded: false,
            lastModified: Date(),
            isTaxDeductible: isTaxDeductible,
            taxDeductiblePercentage: taxDeductiblePercentage
        )
        
        repository.saveMileage(mileage: mileage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionResult in
                    self?.isSaving = false
                    
                    if case .failure(let error) = completionResult {
                        self?.formError = "保存失敗: \(error.localizedDescription)"
                        self?.handleError(error, source: .coreData)
                        completion(false)
                    }
                },
                receiveValue: { _ in
                    completion(true)
                }
            )
            .store(in: &cancellables)
    }
    
    func validateForm() -> Bool {
        // 驗證目的
        if purpose.isEmpty {
            formError = "請輸入行程目的"
            return false
        }
        
        // 驗證距離
        if useDirectDistance {
            if distance == nil || distance! <= 0 {
                formError = "請輸入有效的距離"
                return false
            }
        } else {
            guard let start = startMileage, let end = endMileage else {
                formError = "請輸入起始和結束里程"
                return false
            }
            
            if end <= start {
                formError = "結束里程必須大於起始里程"
                return false
            }
        }
        
        // 全部驗證通過
        formError = nil
        return true
    }
}
