import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            DashboardView()
                .tabItem {
                    Label("儀表板", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            ExpensesView()
                .tabItem {
                    Label("支出", systemImage: "creditcard.fill")
                }
                .tag(1)
            
            MileageView()
                .tabItem {
                    Label("里程", systemImage: "car.fill")
                }
                .tag(2)
            
            WorkHoursView()
                .tabItem {
                    Label("工時", systemImage: "clock.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("更多", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
}
