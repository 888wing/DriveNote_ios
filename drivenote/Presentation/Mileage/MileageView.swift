import SwiftUI
import Combine

struct MileageView: View {
    @StateObject private var viewModel = DIContainer.shared.makeMileageViewModel()
    @State private var showAddForm = false
    @State private var mileageToEdit: Mileage? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 里程統計卡片
                MileageStatsCardView(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.top)
                
                // 使用狀態處理器顯示內容
                ViewStateHandler(state: viewModel.state) { mileages in
                    mileageListContent
                }
                .loading {
                    VStack {
                        ProgressView("加載里程數據...")
                            .padding(.top, 100)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .empty {
                    VStack(spacing: 20) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("暫無里程記錄")
                            .font(.headline)
                        
                        Text("點擊右上角的 + 按鈕添加您的第一個里程記錄")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            showAddForm = true
                        }) {
                            Text("添加里程記錄")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.primaryBlue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .error { error, retry in
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("加載數據時出現錯誤")
                            .font(.headline)
                        
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: retry) {
                            Text("重試")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.primaryBlue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .onRetry {
                    viewModel.loadMileages()
                }
            }
            .navigationTitle("里程記錄")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mileageToEdit = nil
                        showAddForm = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddForm) {
                // 表單關閉後刷新
                viewModel.loadMileages()
            } content: {
                NavigationView {
                    MileageFormView(
                        viewModel: DIContainer.shared.makeMileageFormViewModel(mileage: mileageToEdit),
                        onSaved: {
                            showAddForm = false
                            viewModel.loadMileages()
                        }
                    )
                }
            }
            .onAppear {
                viewModel.loadMileages()
            }
            .refreshable {
                viewModel.loadMileages()
            }
        }
    }
    
    // 里程列表內容
    private var mileageListContent: some View {
        List {
            ForEach(viewModel.mileages) { mileage in
                MileageRowView(mileage: mileage)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        mileageToEdit = mileage
                        showAddForm = true
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteMileage(mileage)
                        } label: {
                            Label("刪除", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct MileageView_Previews: PreviewProvider {
    static var previews: some View {
        MileageView()
    }
}
