import SwiftUI

struct MileageView: View {
    @StateObject private var viewModel = MileageViewModel(repository: DIContainer.shared.mileageRepository)

    var body: some View {
        NavigationView {
            MileageListView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .navigationTitle("里程")
        }
    }
}

struct MileageView_Previews: PreviewProvider {
    static var previews: some View {
        MileageView()
    }
}
