import SwiftUI

struct ExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ExpenseFormViewModel
    
    init(expense: Expense? = nil) {
        let vm = DIContainer.shared.makeExpenseFormViewModel(expense: expense)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background bar
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.lightGray)
                            .frame(height: 4)
                        
                        // Progress bar
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.primaryBlue)
                            .frame(width: CGFloat(viewModel.formStep) / 3 * geometry.size.width, height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, Spacing.large)
                .padding(.top, Spacing.large)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.large) {
                        // Step title
                        Text(viewModel.getStepTitle())
                            .font(.titleLarge)
                            .padding(.horizontal, Spacing.large)
                        
                        // Form steps
                        if viewModel.formStep == 1 {
                            basicInfoForm
                        } else if viewModel.formStep == 2 {
                            detailsForm
                        } else {
                            taxInfoForm
                        }
                    }
                    .padding(.bottom, 100) // Space for bottom buttons
                    .padding(.top, Spacing.medium)
                }
                
                Spacer()
                
                // Bottom navigation buttons
                bottomNavigationButtons
                    .background(Color(.systemBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.formTitle)
                        .font(.headline)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .alert("錯誤", isPresented: Binding<Bool>(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("確定", role: .cancel) { }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Form Sections
    
    private var basicInfoForm: some View {
        VStack(spacing: Spacing.large) {
            // Category selection
            VStack(alignment: .leading, spacing: 8) {
                Text("支出類別")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.medium) {
                        ForEach(ExpenseCategory.allCases) { category in
                            CategoryButton(
                                title: category.displayName,
                                icon: category.icon,
                                isSelected: viewModel.category == category,
                                action: {
                                    viewModel.category = category
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Date picker
            DatePickerField(
                label: "日期",
                icon: "calendar",
                date: $viewModel.date
            )
            
            // Amount input
            VStack(alignment: .leading, spacing: 8) {
                Text("金額")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                HStack {
                    Image(systemName: "sterling.sign")
                        .foregroundColor(.secondary)
                        .frame(width: 24)
                    
                    Text("£")
                        .foregroundColor(.secondary)
                        .padding(.trailing, 2)
                    
                    TextField("0.00", text: $viewModel.amountString)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.amountError != nil ? Color.red : Color.lightGray, lineWidth: 1)
                )
                
                if let amountError = viewModel.amountError {
                    Text(amountError)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
            }
        }
        .padding(.horizontal, Spacing.large)
    }
    
    private var detailsForm: some View {
        VStack(spacing: Spacing.large) {
            // Description
            ModernTextField(
                label: "描述",
                icon: "text.alignleft", 
                placeholder: "輸入描述（可選）",
                text: $viewModel.description
            )
            
            // Receipt upload (placeholder for now)
            VStack(alignment: .leading, spacing: 8) {
                Text("收據")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                ZStack {
                    if let receiptImage = viewModel.receiptImage {
                        Image(uiImage: receiptImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    } else {
                        VStack(spacing: Spacing.medium) {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("拍攝或上傳收據")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // 上傳按鈕 (MVP 階段只設置 UI，不實現功能)
                            Button(action: {
                                // 收據上傳功能將在未來實現
                            }) {
                                Text("選擇收據")
                                    .font(.footnote)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.primaryBlue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.lightGray, lineWidth: 1)
                        )
                    }
                }
            }
            
            // Category-specific fields
            if viewModel.category == .fuel {
                fuelDetailsFields
            } else if viewModel.category == .maintenance {
                maintenanceDetailsFields
            }
        }
        .padding(.horizontal, Spacing.large)
    }
    
    private var taxInfoForm: some View {
        VStack(spacing: Spacing.large) {
            // Tax deductible switch
            VStack(alignment: .leading, spacing: 8) {
                Text("稅務信息")
                    .font(.titleMedium)
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("此支出可抵稅")
                                .font(.bodyMedium)
                            
                            if viewModel.isTaxDeductible {
                                Text("此支出將計入年度稅務報表")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.isTaxDeductible)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .accentGreen))
                    }
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(12)
                }
            }
            
            // Tax deductible percentage
            if viewModel.isTaxDeductible {
                VStack(alignment: .leading, spacing: 8) {
                    Text("可抵稅比例")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(viewModel.taxDeductiblePercentage)%")
                                .font(.headline)
                                .monospacedDigit()
                            
                            Spacer()
                            
                            if viewModel.taxDeductiblePercentage < 100 {
                                Text("部分商業用途")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("完全商業用途")
                                    .font(.caption)
                                    .foregroundColor(.accentGreen)
                            }
                        }
                        .padding(.bottom, 8)
                        
                        Slider(
                            value: Binding(
                                get: { Double(viewModel.taxDeductiblePercentage) },
                                set: { viewModel.taxDeductiblePercentage = Int($0) }
                            ),
                            in: 0...100,
                            step: 5
                        )
                        .accentColor(.accentGreen)
                    }
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(12)
                }
            }
            
            // Tax tip
            if let taxTip = viewModel.getTaxTipForCategory() {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.primaryBlue)
                    
                    Text(taxTip)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding()
                .background(Color.primaryBlue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, Spacing.large)
    }
    
    // Category-specific form fields
    private var fuelDetailsFields: some View {
        VStack(spacing: Spacing.medium) {
            Text("燃料詳細信息")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 品牌選擇 (placeholder for MVP)
            VStack(alignment: .leading, spacing: 8) {
                Text("燃料品牌")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                HStack {
                    Image(systemName: "fuelpump.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 24)
                    
                    Text("請選擇品牌")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.lightGray, lineWidth: 1)
                )
            }
        }
    }
    
    private var maintenanceDetailsFields: some View {
        VStack(spacing: Spacing.medium) {
            Text("維修詳細信息")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 維修類型選擇 (placeholder for MVP)
            VStack(alignment: .leading, spacing: 8) {
                Text("維修類型")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                HStack {
                    Image(systemName: "wrench.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 24)
                    
                    Text("請選擇維修類型")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.lightGray, lineWidth: 1)
                )
            }
        }
    }
    
    // Bottom navigation buttons
    private var bottomNavigationButtons: some View {
        VStack {
            Divider()
            
            HStack {
                // Back button (for steps 2 and 3)
                if viewModel.formStep > 1 {
                    Button(action: {
                        viewModel.previousStep()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("上一步")
                        }
                        .padding()
                        .foregroundColor(.primary)
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
                
                // Next/Save button
                if viewModel.formStep < 3 {
                    Button(action: {
                        viewModel.nextStep()
                    }) {
                        HStack {
                            Text("下一步")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .buttonStyle(GradientButtonStyle())
                    .disabled(!viewModel.formIsValid)
                } else {
                    Button(action: {
                        viewModel.saveExpense {
                            dismiss()
                        }
                    }) {
                        HStack {
                            Text(viewModel.isEditMode ? "保存修改" : "添加支出")
                            Image(systemName: "checkmark")
                        }
                    }
                    .buttonStyle(GradientButtonStyle())
                    .disabled(!viewModel.formIsValid || viewModel.isLoading)
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.medium)
        }
    }
}

// Custom button style for gradient buttons
struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.primaryBlue, .deepBlue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct ExpenseFormView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseFormView()
    }
}
