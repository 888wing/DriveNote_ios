import SwiftUI

struct MileageView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Placeholder for MVP phase 1
                // In a real implementation, this would use MileageListViewModel
                
                Image(systemName: "car.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryBlue.opacity(0.8))
                    .padding(.bottom, 20)
                
                Text("里程記錄")
                    .font(.title)
                    .bold()
                
                Text("此功能正在開發中")
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
                
                // Placeholder button - not functional in MVP phase 1
                Button(action: {
                    // Will be implemented in next phase
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("添加里程記錄")
                    }
                    .padding()
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("里程")
        }
    }
}

#Preview {
    MileageView()
}
