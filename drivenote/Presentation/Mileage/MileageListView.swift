import SwiftUI

struct MileageListView: View {
    @ObservedObject var viewModel: MileageViewModel
    @State private var showAddForm = false
    @State private var selectedMileage: Mileage?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.mileages) { mileage in
                    Button(action: {
                        selectedMileage = mileage
                        showAddForm = true
                    }) {
                        VStack(alignment: .leading) {
                            Text(mileage.date, style: .date)
                                .font(.headline)
                            Text("\(mileage.distance, specifier: "%.1f") km - \(mileage.purpose ?? "-")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteMileage)
            }
            .navigationTitle("Mileage Records")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedMileage = nil
                        showAddForm = true
                    }) {
                        Label("Add", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showAddForm) {
                MileageFormView(viewModel: viewModel.formViewModel(for: selectedMileage))
            }
        }
    }
}
