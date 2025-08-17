import SwiftUI

struct CurrencySelectorView: View {
    @EnvironmentObject var expenseService: ExpenseService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Currency.supportedCurrencies) { currency in
                    CurrencyRow(
                        currency: currency,
                        isSelected: currency == expenseService.selectedCurrency
                    ) {
                        expenseService.selectCurrency(currency)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Currency")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CurrencyRow: View {
    let currency: Currency
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currency.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(currency.code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CurrencySelectorView()
        .environmentObject(ExpenseService())
}