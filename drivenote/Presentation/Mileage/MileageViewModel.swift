import Foundation
import Combine

class MileageViewModel: ObservableObject {
    @Published var mileages: [Mileage] = []
    @Published var date: Date = Date()
    @Published var startMileage: Double? = nil
    @Published var endMileage: Double? = nil
    @Published var purpose: String = ""
    @Published var isTaxDeductible: Bool = false
    @Published var taxDeductiblePercentage: Int = 0
    @Published var isEditing: Bool = false
    @Published var error: Error?
    private let repository: MileageRepository
    private var editingMileage: Mileage?
    private var cancellables = Set<AnyCancellable>()
    
    var isValid: Bool {
        guard let start = startMileage, let end = endMileage else { return false }
        return end > start && !purpose.isEmpty
    }
    
    init(repository: MileageRepository) {
        self.repository = repository
        loadMileages()
    }
    
    func loadMileages() {
        _ = repository.getAllMileage()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] mileages in
                self?.mileages = mileages
            })
    }
    
    func save() {
        guard isValid else { return }
        let distance = (endMileage ?? 0) - (startMileage ?? 0)
        let mileage = Mileage(
            id: editingMileage?.id ?? UUID(),
            date: date,
            startMileage: startMileage,
            endMileage: endMileage,
            distance: distance,
            purpose: purpose,
            isUploaded: false,
            lastModified: Date(),
            isTaxDeductible: isTaxDeductible,
            taxDeductiblePercentage: taxDeductiblePercentage
        )
        _ = repository.saveMileage(mileage: mileage)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] _ in
                self?.loadMileages()
            })
    }
    
    func deleteMileage(at offsets: IndexSet) {
        for index in offsets {
            let mileage = mileages[index]
            _ = repository.deleteMileage(id: mileage.id)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                    self?.mileages.remove(at: index)
                })
        }
    }
    
    func formViewModel(for mileage: Mileage?) -> MileageViewModel {
        let vm = MileageViewModel(repository: repository)
        if let m = mileage {
            vm.editingMileage = m
            vm.date = m.date
            vm.startMileage = m.startMileage
            vm.endMileage = m.endMileage
            vm.purpose = m.purpose ?? ""
            vm.isTaxDeductible = m.isTaxDeductible
            vm.taxDeductiblePercentage = m.taxDeductiblePercentage
            vm.isEditing = true
        }
        return vm
    }
}
