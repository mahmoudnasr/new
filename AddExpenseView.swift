import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var expenseService: ExpenseService
    @State private var description = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.other
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section("Expense Details") {
                    TextField("Description", text: $description)
                    
                    TextField("Amount (USD)", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var canSave: Bool {
        !description.isEmpty && !amount.isEmpty && Decimal(string: amount) != nil
    }
    
    private func saveExpense() {
        guard let amountValue = Decimal(string: amount) else { return }
        
        let newExpense = Expense(
            amount: amountValue,
            description: description,
            category: selectedCategory,
            date: date
        )
        
        expenseService.addExpense(newExpense)
        dismiss()
    }
}