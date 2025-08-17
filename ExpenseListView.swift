import SwiftUI

struct ExpenseListView: View {
    @State private var expenses: [Expense] = []
    @State private var isAddingExpense = false

    var body: some View {
        List {
            ForEach(expenses) { expense in
                HStack {
                    Text(expense.title)
                    Spacer()
                    Text("$\(expense.amount, specifier: \"%.2f\")")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Expenses")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isAddingExpense = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingExpense) {
            AddExpenseView { newExpense in
                expenses.append(newExpense)
            }
        }
    }
}