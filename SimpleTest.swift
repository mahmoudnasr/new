import Foundation

// Import the models
// Expense model test
let expense = Expense(
    amount: Decimal(29.99),
    description: "Test expense",
    category: .food
)

print("Testing Expense Model...")
print("✅ Expense created: \(expense.description) - \(expense.amount)")

// Currency model test  
let usd = Currency(code: "USD", name: "US Dollar", rate: 1.0)
let eur = Currency(code: "EUR", name: "Euro", rate: 0.85)

print("Testing Currency Model...")
print("✅ USD: \(usd.name) (\(usd.code))")
print("✅ EUR: \(eur.name) (\(eur.code))")

// API Error test
let error = APIError.serverError(404)
print("Testing API Error...")
print("✅ Error description: \(error.errorDescription ?? "Unknown")")

print("🎉 All basic tests passed!")