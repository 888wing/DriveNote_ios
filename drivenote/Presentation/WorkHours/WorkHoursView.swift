import SwiftUI

struct WorkHoursView: View {
    @State private var isTimerRunning = false
    @State private var timerStartTime: Date?
    @State private var elapsedSeconds: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Timer Card
                    ModernCard(title: "工作計時器", icon: "clock.fill", tint: .primaryBlue) {
                        VStack(spacing: 16) {
                            // Timer display
                            Text(formatElapsedTime())
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundColor(isTimerRunning ? .accentGreen : .primary)
                                .padding(.vertical, 10)
                            
                            // Timer controls
                            HStack(spacing: 30) {
                                // Start/Stop button
                                Button(action: toggleTimer) {
                                    ZStack {
                                        Circle()
                                            .fill(isTimerRunning ? Color.red : Color.accentGreen)
                                            .frame(width: 70, height: 70)
                                        
                                        Image(systemName: isTimerRunning ? "stop.fill" : "play.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                // Reset button
                                Button(action: resetTimer) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 20))
                                            .foregroundColor(.primary)
                                    }
                                }
                                .disabled(elapsedSeconds == 0)
                                .opacity(elapsedSeconds == 0 ? 0.5 : 1)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .padding(.horizontal)
                    
                    // Weekly Summary Card - Placeholder for MVP
                    ModernCard(title: "本週工作時數", icon: "calendar", tint: .primaryBlue) {
                        VStack(spacing: 16) {
                            HStack {
                                Text("總計工時")
                                    .font(.body)
                                
                                Spacer()
                                
                                Text("0時00分")
                                    .font(.title3)
                                    .bold()
                            }
                            
                            HStack {
                                Text("預計收入")
                                    .font(.body)
                                
                                Spacer()
                                
                                Text("£0.00")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.accentGreen)
                            }
                            
                            Divider()
                                .padding(.vertical, 5)
                            
                            Button(action: {
                                // Will be implemented in next phase
                            }) {
                                Text("查看詳細記錄")
                                    .font(.footnote)
                                    .foregroundColor(.primaryBlue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Info card with usage tips
                    ModernCard(title: "使用說明", icon: "info.circle", tint: .primaryBlue) {
                        VStack(alignment: .leading, spacing: 12) {
                            infoRow(icon: "play.circle", text: "點擊開始按鈕開始計時")
                            infoRow(icon: "stop.circle", text: "點擊停止按鈕結束計時")
                            infoRow(icon: "arrow.clockwise", text: "點擊重置按鈕清除計時")
                            infoRow(icon: "checkmark.circle", text: "計時結束後會自動保存記錄")
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("工時")
        }
    }
    
    // Helper function to format elapsed time
    private func formatElapsedTime() -> String {
        let hours = Int(elapsedSeconds) / 3600
        let minutes = (Int(elapsedSeconds) % 3600) / 60
        let seconds = Int(elapsedSeconds) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // Toggle timer state
    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    // Start the timer
    private func startTimer() {
        timerStartTime = Date()
        isTimerRunning = true
        
        // Create a timer that fires every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = timerStartTime {
                elapsedSeconds = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    // Stop the timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        
        // In a real app, this would save the work hours record
        saveWorkHours()
    }
    
    // Reset the timer
    private func resetTimer() {
        stopTimer()
        elapsedSeconds = 0
        timerStartTime = nil
    }
    
    // Placeholder for saving work hours
    private func saveWorkHours() {
        // This would integrate with the WorkHoursRepository in a complete implementation
        print("Work hours saved: \(formatElapsedTime())")
    }
    
    // Helper view for info rows
    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primaryBlue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    WorkHoursView()
}
