import Foundation
import CoreData

// MARK: - Expense Mappers
extension CDExpense {
    
    func toDomain() -> Expense {
        // 從 Core Data 轉換到 Domain 模型時添加日誌以便調試
        print("CDExpense - 轉換為域模型，ID: \(id?.uuidString ?? "nil")")
        
        let receiptIds = (receipts?.allObjects as? [CDReceipt])?.compactMap { $0.id } ?? []
        
        return Expense(
            id: id ?? UUID(),
            date: date ?? Date(),
            amount: amount,
            category: mapStringToCategory(category ?? "other"),
            description: descriptionText,
            isTaxDeductible: isTaxDeductible,
            taxDeductiblePercentage: Int(taxDeductiblePercentage),
            creationMethod: mapStringToCreationMethod(creationMethod ?? "manual"),
            isUploaded: isUploaded,
            lastModified: lastModified ?? Date(),
            receiptIds: receiptIds.isEmpty ? nil : receiptIds,
            relatedMileageId: relatedMileageId
        )
    }
    
    private func mapStringToCategory(_ categoryString: String) -> ExpenseCategory {
        return ExpenseCategory(rawValue: categoryString) ?? .other
    }
    
    private func mapStringToCreationMethod(_ methodString: String) -> Expense.CreationMethod {
        return Expense.CreationMethod(rawValue: methodString) ?? .manual
    }
    
    func update(with expense: Expense, context: NSManagedObjectContext) {
        id = expense.id
        date = expense.date
        amount = expense.amount
        category = expense.category.rawValue
        descriptionText = expense.description
        isTaxDeductible = expense.isTaxDeductible
        taxDeductiblePercentage = Int16(expense.taxDeductiblePercentage)
        creationMethod = expense.creationMethod.rawValue
        isUploaded = expense.isUploaded
        lastModified = expense.lastModified
        relatedMileageId = expense.relatedMileageId
    }
    
    static func createFrom(expense: Expense, context: NSManagedObjectContext) -> CDExpense {
        let cdExpense = CDExpense(context: context)
        cdExpense.update(with: expense, context: context)
        return cdExpense
    }
}

// MARK: - Mileage Mappers
extension CDMileage {
    
    func toDomain() -> Mileage {
        return Mileage(
            id: id ?? UUID(),
            date: date ?? Date(),
            startMileage: startMileage, // 直接使用，因為它在Core Data中就是Double
            endMileage: endMileage,    // 直接使用，因為它在Core Data中就是Double
            distance: distance,
            purpose: purpose,
            isUploaded: isUploaded,
            lastModified: lastModified ?? Date(),
            isTaxDeductible: isTaxDeductible,
            taxDeductiblePercentage: Int(taxDeductiblePercentage),
            relatedFuelExpenseId: relatedFuelExpenseId
        )
    }
    
    func update(with mileage: Mileage, context: NSManagedObjectContext) {
        id = mileage.id
        date = mileage.date
        startMileage = mileage.startMileage ?? 0 // 直接賦值，但需處理nil (Core Data中非可選需給預設值)
        endMileage = mileage.endMileage ?? 0    // 直接賦值，但需處理nil
        distance = mileage.distance
        purpose = mileage.purpose
        isUploaded = mileage.isUploaded
        lastModified = mileage.lastModified
        isTaxDeductible = mileage.isTaxDeductible
        taxDeductiblePercentage = Int16(mileage.taxDeductiblePercentage)
        relatedFuelExpenseId = mileage.relatedFuelExpenseId
    }
    
    static func createFrom(mileage: Mileage, context: NSManagedObjectContext) -> CDMileage {
        let cdMileage = CDMileage(context: context)
        cdMileage.update(with: mileage, context: context)
        return cdMileage
    }
}

// MARK: - WorkHours Mappers
extension CDWorkHours {
    
    func toDomain() -> WorkHours {
        return WorkHours(
            id: id ?? UUID(),
            date: date ?? Date(),
            startTime: startTime,
            endTime: endTime,
            totalHours: totalHours,
            isUploaded: isUploaded,
            lastModified: lastModified ?? Date(),
            notes: notes
        )
    }
    
    func update(with workHours: WorkHours, context: NSManagedObjectContext) {
        id = workHours.id
        date = workHours.date
        startTime = workHours.startTime
        endTime = workHours.endTime
        totalHours = workHours.totalHours
        isUploaded = workHours.isUploaded
        lastModified = workHours.lastModified
        notes = workHours.notes
    }
    
    static func createFrom(workHours: WorkHours, context: NSManagedObjectContext) -> CDWorkHours {
        let cdWorkHours = CDWorkHours(context: context)
        cdWorkHours.update(with: workHours, context: context)
        return cdWorkHours
    }
}

// MARK: - Receipt Mappers
extension CDReceipt {
    
    func toDomain() -> Receipt {
        return Receipt(
            id: id ?? UUID(),
            filePath: filePath ?? "",
            uploadTimestamp: uploadTimestamp ?? Date(),
            ocrStatus: mapStringToOCRStatus(ocrStatus ?? "pending"),
            ocrResultJson: ocrResultJson,
            isUploaded: isUploaded,
            expenseId: expense?.id
        )
    }
    
    private func mapStringToOCRStatus(_ statusString: String) -> Receipt.OCRStatus {
        return Receipt.OCRStatus(rawValue: statusString) ?? .pending
    }
    
    func update(with receipt: Receipt, context: NSManagedObjectContext) {
        id = receipt.id
        filePath = receipt.filePath
        uploadTimestamp = receipt.uploadTimestamp
        ocrStatus = receipt.ocrStatus.rawValue
        ocrResultJson = receipt.ocrResultJson
        isUploaded = receipt.isUploaded
        
        if let expenseId = receipt.expenseId,
           let cdExpense = try? context.fetch(NSFetchRequest<CDExpense>(entityName: "CDExpense")).first(where: { $0.id == expenseId }) {
            expense = cdExpense
        }
    }
    
    static func createFrom(receipt: Receipt, context: NSManagedObjectContext) -> CDReceipt {
        let cdReceipt = CDReceipt(context: context)
        cdReceipt.update(with: receipt, context: context)
        return cdReceipt
    }
}

// MARK: - Income Mappers
extension CDIncome {
    
    func toDomain() -> Income {
        return Income(
            id: id ?? UUID(),
            date: date ?? Date(),
            amount: amount,
            tipAmount: tipAmount,
            source: mapStringToSource(source ?? "Uber"),
            notes: notes,
            isUploaded: isUploaded,
            lastModified: lastModified ?? Date()
        )
    }
    
    private func mapStringToSource(_ sourceString: String) -> Income.IncomeSource {
        return Income.IncomeSource(rawValue: sourceString) ?? .uber
    }
    
    func update(with income: Income, context: NSManagedObjectContext) {
        id = income.id
        date = income.date
        amount = income.amount
        tipAmount = income.tipAmount
        source = income.source.rawValue
        notes = income.notes
        isUploaded = income.isUploaded
        lastModified = income.lastModified
    }
    
    static func createFrom(income: Income, context: NSManagedObjectContext) -> CDIncome {
        let cdIncome = CDIncome(context: context)
        cdIncome.update(with: income, context: context)
        return cdIncome
    }
}
