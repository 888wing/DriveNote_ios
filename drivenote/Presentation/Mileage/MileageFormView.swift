import SwiftUI

struct MileageFormView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    @Environment(\.presentationMode) var presentationMode
    var onSaved: (() -> Void)? = nil
    
    var body: some View {
        Form {
            Section(header: Text("基本信息")) {
                DatePicker("日期", selection: $viewModel.date, displayedComponents: .date)
                
                TextField("目的", text: $viewModel.purpose)
                    .autocapitalization(.words)
            }
            
            Section(header: Text("里程信息")) {
                Toggle("直接輸入總里程", isOn: $viewModel.useDirectDistance)
                
                if viewModel.useDirectDistance {
                    HStack {
                        Text("總里程")
                        Spacer()
                        TextField("", value: $viewModel.distance, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("公里")
                    }
                } else {
                    HStack {
                        Text("起始里程")
                        Spacer()
                        TextField("", value: $viewModel.startMileage, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("公里")
                    }
                    
                    HStack {
                        Text("結束里程")
                        Spacer()
                        TextField("", value: $viewModel.endMileage, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("公里")
                    }
                    
                    if let start = viewModel.startMileage,
                       let end = viewModel.endMileage,
                       end > start {
                        HStack {
                            Text("總里程")
                            Spacer()
                            Text("\(end - start, specifier: "%.1f") 公里")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section(header: Text("稅務信息")) {
                Toggle("可抵稅", isOn: $viewModel.isTaxDeductible)
                
                if viewModel.isTaxDeductible {
                    VStack {
                        HStack {
                            Text("抵稅比例: \(viewModel.taxDeductiblePercentage)%")
                            Spacer()
                        }
                        
                        Slider(value: Binding(
                            get: { Double(viewModel.taxDeductiblePercentage) },
                            set: { viewModel.taxDeductiblePercentage = Int($0) }
                        ), in: 0...100, step: 5)
                    }
                }
            }
            
            if let formError = viewModel.formError {
                Section {
                    Text(formError)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "編輯里程記錄" : "添加里程記錄")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(viewModel.isEditing ? "保存" : "添加") {
                    viewModel.save { success in
                        if success {
                            onSaved?()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .disabled(!viewModel.isValid || viewModel.isSaving)
            }
        }
        .overlay(
            viewModel.isSaving ? 
                VStack {
                    ProgressView("保存中...")
                        .padding()
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
                : nil
        )
        .disabled(viewModel.isSaving)
    }
}

struct MileageFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MileageFormView(
                viewModel: MileageFormViewModel(
                    repository: PreviewMileageRepository()
                )
            )
        }
    }
}

import Combine

// 預覽用的模擬存儲庫
private class PreviewMileageRepository: MileageRepository {
    func getAllMileage() -> AnyPublisher<[Mileage], Error> {
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getMileageById(id: UUID) -> AnyPublisher<Mileage?, Error> {
        return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getMileageByDateRange(start: Date, end: Date) -> AnyPublisher<[Mileage], Error> {
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func saveMileage(mileage: Mileage) -> AnyPublisher<Mileage, Error> {
        return Just(mileage).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func deleteMileage(id: UUID) -> AnyPublisher<Void, Error> {
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    // 實現剩餘的 MileageRepository 方法
    func syncMileage() -> AnyPublisher<Void, Error> {
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getUnsyncedMileage() -> AnyPublisher<[Mileage], Error> {
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func markMileageAsSynced(id: UUID) -> AnyPublisher<Void, Error> {
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getTotalMileage(start: Date, end: Date) -> AnyPublisher<Double, Error> {
        return Just(0.0).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getMileageByFuelExpenseId(expenseId: UUID) -> AnyPublisher<[Mileage], Error> {
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
