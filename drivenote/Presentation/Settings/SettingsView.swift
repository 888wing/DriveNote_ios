import SwiftUI

struct SettingsView: View {
    @State private var isSyncEnabled = false
    @State private var showDebugInfo = false
    @State private var showAboutSheet = false
    @State private var currency = "GBP"
    @State private var distanceUnit = "miles"
    
    let currencies = ["GBP", "EUR", "USD"]
    let distanceUnits = ["miles", "kilometers"]
    
    // App version info
    let appVersion = "1.0.0"
    let buildNumber = "1"
    
    var body: some View {
        NavigationView {
            List {
                // App info section
                Section {
                    HStack {
                        VStack(alignment: .center) {
                            Image(systemName: "car.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.primaryBlue)
                            
                            Text("DriveNote")
                                .font(.title2)
                                .bold()
                            
                            Text("版本 \(appVersion) (\(buildNumber))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
                
                // Preferences
                Section(header: Text("偏好設置")) {
                    // Currency
                    Picker(selection: $currency, label: HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.primaryBlue)
                        Text("貨幣")
                    }) {
                        ForEach(currencies, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    // Distance unit
                    Picker(selection: $distanceUnit, label: HStack {
                        Image(systemName: "ruler")
                            .foregroundColor(.primaryBlue)
                        Text("距離單位")
                    }) {
                        ForEach(distanceUnits, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                // Cloud Sync - Placeholder for future development
                Section(header: Text("雲端同步")) {
                    Toggle(isOn: $isSyncEnabled) {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(.primaryBlue)
                            Text("啟用雲端同步")
                        }
                    }
                    .disabled(true) // Disabled for MVP
                    
                    if isSyncEnabled {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.primaryBlue)
                            Text("最後同步時間")
                            Spacer()
                            Text("從未")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.primaryBlue)
                        Text("雲端同步功能將在未來版本推出")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // About and Info
                Section(header: Text("關於")) {
                    Button(action: {
                        showAboutSheet = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.primaryBlue)
                            Text("關於DriveNote")
                        }
                    }
                    
                    // Privacy Policy - Would link to actual policy in production
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.primaryBlue)
                            Text("隱私政策")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                    
                    // Terms of Service - Would link to actual terms in production
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.primaryBlue)
                            Text("使用條款")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                }
                
                // Debug section (only in development)
                Section(header: Text("開發者選項")) {
                    Button(action: {
                        showDebugInfo.toggle()
                    }) {
                        HStack {
                            Image(systemName: "ladybug")
                                .foregroundColor(.primaryBlue)
                            Text("顯示調試信息")
                        }
                    }
                    
                    if showDebugInfo {
                        HStack {
                            Text("設備ID")
                            Spacer()
                            Text("DEV-\(UUID().uuidString.prefix(8))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("構建類型")
                            Spacer()
                            Text("DEBUG")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // App credits
                Section {
                    VStack(alignment: .center) {
                        Text("© 2025 DriveNote.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("為英國 Uber 司機開發")
                            .font(.caption2)
                            .foregroundColor(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("設置")
            .sheet(isPresented: $showAboutSheet) {
                AboutView()
            }
        }
    }
}

// About sheet view
struct AboutView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Image(systemName: "car.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.primaryBlue)
                    
                    Text("DriveNote")
                        .font(.title)
                        .bold()
                    
                    Text("版本 1.0.0 (1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                VStack(spacing: 15) {
                    Text("為Uber司機設計的一站式管理工具")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("DriveNote幫助您追蹤收入、支出、里程和工時，簡化稅務申報流程，讓您專注於駕駛體驗。")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    VStack(spacing: 8) {
                        FeatureRow(icon: "dollarsign.square", text: "輕鬆追蹤收入與支出")
                        FeatureRow(icon: "car", text: "記錄里程，自動計算成本")
                        FeatureRow(icon: "clock", text: "工時記錄，了解實際時薪")
                        FeatureRow(icon: "percent", text: "識別可抵稅項目，節省稅費")
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Text("© 2025 DriveNote. 保留所有權利。")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .navigationBarTitle("關於", displayMode: .inline)
            .navigationBarItems(trailing: Button("關閉") {
                // This will be handled by the sheet dismissal
            })
        }
    }
}

// Feature row for AboutView
struct FeatureRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.primaryBlue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    SettingsView()
}
