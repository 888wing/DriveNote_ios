import SwiftUI

struct MileageStatsCardView: View {
    @ObservedObject var viewModel: MileageViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("里程統計")
                    .font(.headline)
                
                Spacer()
                
                // 期間選擇器
                Picker("", selection: $viewModel.selectedPeriod) {
                    ForEach(Period.allCases) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: viewModel.selectedPeriod) { newValue in
                    viewModel.filterMileagesByPeriod(newValue)
                }
            }
            
            Divider()
            
            HStack(spacing: 16) {
                StatItemView(
                    title: "總里程",
                    value: String(format: "%.1f公里", viewModel.totalMileage),
                    icon: "speedometer",
                    color: .primaryBlue
                )
                
                StatItemView(
                    title: "可抵稅里程",
                    value: String(format: "%.1f公里", viewModel.taxDeductibleMileage),
                    icon: "percent",
                    color: .accentGreen
                )
            }
            
            HStack(spacing: 16) {
                StatItemView(
                    title: "平均每日",
                    value: String(format: "%.1f公里", viewModel.averageDailyMileage),
                    icon: "calendar",
                    color: .expenseOrange
                )
                
                StatItemView(
                    title: "總行程數",
                    value: "\(viewModel.totalTrips)次",
                    icon: "mappin.and.ellipse",
                    color: .deepBlue
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.headline)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}

struct MileageStatsCardView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = MileageViewModel(repository: MockMileageRepository())
        
        return VStack {
            MileageStatsCardView(viewModel: mockViewModel)
                .padding()
        }
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}

import Combine

// 預覽用的模擬存儲庫
private class MockMileageRepository: MileageRepository {
    func getAllMileage() -> AnyPublisher<[Mileage], Error> {
        return Just([
            Mileage(
                id: UUID(),
                date: Date(),
                startMileage: 1000,
                endMileage: 1050,
                distance: 50,
                purpose: "市區接送",
                isUploaded: false,
                lastModified: Date(),
                isTaxDeductible: true,
                taxDeductiblePercentage: 100
            ),
            Mileage(
                id: UUID(),
                date: Date().addingTimeInterval(-86400),
                startMileage: 950,
                endMileage: 1000,
                distance: 50,
                purpose: "機場接送",
                isUploaded: false,
                lastModified: Date(),
                isTaxDeductible: true,
                taxDeductiblePercentage: 100
            )
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    func getMileageById(id: UUID) -> AnyPublisher<Mileage?, Error> {
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getMileageByDateRange(start: Date, end: Date) -> AnyPublisher<[Mileage], Error> {
        return getAllMileage()
    }
    
    func saveMileage(mileage: Mileage) -> AnyPublisher<Mileage, Error> {
        return Just(mileage)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteMileage(id: UUID) -> AnyPublisher<Void, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
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
        return Just(100.0).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getMileageByFuelExpenseId(expenseId: UUID) -> AnyPublisher<[Mileage], Error> {
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
