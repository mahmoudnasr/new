import SwiftUI

struct AddExpenseView: View {
    @Environment(\".dismiss\") var dismiss
    @State private var title = \"\"
    @State private var amount = \"\"

    var onAdd: (Expense) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField(\"Title\", text: &$title)
                TextField(\"Amount\", text: &$amount)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle(\"Add Expense\")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(\"Cancel\") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(\"Save\") {
                        if let amountValue = Double(amount) {
                            let newExpense = Expense(
                                title: title,
                                amount: amountValue,
                                date: Date()
                            )
                            onAdd(newExpense)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}