import SwiftUI

struct ExpenseListView: View {
    @EnvironmentObject var expenseService: ExpenseService
    @State private var isAddingExpense = false
    @State private var showingCurrencySelector = false

    var body: some View {
        List {
            ForEach(expenseService.expenses) { expense in
                ExpenseRowView(expense: expense)
            }
            .onDelete(perform: deleteExpenses)
        }
        .navigationTitle("Expenses")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingCurrencySelector = true
                }) {
                    HStack {
                        Text(expenseService.selectedCurrency.code)
                            .font(.headline)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        Task {
                            await expenseService.fetchExchangeRates()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(expenseService.isLoading)
                    
                    Button(action: {
                        isAddingExpense = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingExpense) {
            AddExpenseView()
        }
        .sheet(isPresented: $showingCurrencySelector) {
            CurrencySelectorView()
        }
        .overlay {
            if expenseService.isLoading {
                ProgressView("Updating rates...")
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
            }
        }
        .alert("Error", isPresented: .constant(expenseService.errorMessage != nil)) {
            Button("OK") {
                expenseService.errorMessage = nil
            }
        } message: {
            Text(expenseService.errorMessage ?? "")
        }
        .task {
            await expenseService.fetchExchangeRates()
        }
    }
    
    private func deleteExpenses(offsets: IndexSet) {
        for index in offsets {
            expenseService.removeExpense(expenseService.expenses[index])
        }
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    @EnvironmentObject var expenseService: ExpenseService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.headline)
                
                HStack {
                    Text(expense.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text(expense.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(expenseService.formattedAmount(expense.amount, currency: expenseService.selectedCurrency))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}