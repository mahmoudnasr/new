import Foundation
import Combine

@MainActor
class ExpenseService: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var selectedCurrency: Currency = Currency.supportedCurrencies[0] // USD
    @Published var exchangeRates: [String: Double] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
        loadSampleData()
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }
    
    func removeExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
    }
    
    func fetchExchangeRates() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.fetchExchangeRates()
            exchangeRates = response.rates
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func convertAmount(_ amount: Decimal, to currency: Currency) -> Decimal {
        guard currency.code != "USD" else { return amount }
        
        let rate = exchangeRates[currency.code] ?? currency.rate
        return amount * Decimal(rate)
    }
    
    func selectCurrency(_ currency: Currency) {
        selectedCurrency = currency
    }
    
    func formattedAmount(_ amount: Decimal, currency: Currency = Currency.supportedCurrencies[0]) -> String {
        let convertedAmount = convertAmount(amount, to: currency)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: convertedAmount as NSDecimalNumber) ?? "\(currency.code) \(convertedAmount)"
    }
    
    private func loadSampleData() {
        expenses = [
            Expense(
                amount: Decimal(29.99),
                description: "Lunch with colleagues",
                category: .food
            ),
            Expense(
                amount: Decimal(15.50),
                description: "Bus ticket",
                category: .transportation
            ),
            Expense(
                amount: Decimal(120.00),
                description: "Monthly gym membership",
                category: .health
            )
        ]
    }
}