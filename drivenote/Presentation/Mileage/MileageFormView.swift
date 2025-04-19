import SwiftUI

struct MileageFormView: View {
    @ObservedObject var viewModel: MileageViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
            TextField("Start Mileage", value: $viewModel.startMileage, formatter: NumberFormatter())
                .keyboardType(.decimalPad)
            TextField("End Mileage", value: $viewModel.endMileage, formatter: NumberFormatter())
                .keyboardType(.decimalPad)
            TextField("Purpose", text: $viewModel.purpose)
            Toggle("Tax Deductible", isOn: $viewModel.isTaxDeductible)
            if viewModel.isTaxDeductible {
                Stepper(value: $viewModel.taxDeductiblePercentage, in: 0...100, step: 10) {
                    Text("Deductible %: \(viewModel.taxDeductiblePercentage)%")
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Mileage" : "Add Mileage")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.save()
                    presentationMode.wrappedValue.dismiss()
                }.disabled(!viewModel.isValid)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { presentationMode.wrappedValue.dismiss() }
            }
        }
    }
}
