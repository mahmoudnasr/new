import Foundation

// Simple test runner for business logic
class TestRunner {
    static func runAllTests() {
        print("Running Expense Tracker Tests...")
        
        testExpenseModel()
        testCurrencyModel()
        testAPIService()
        testExpenseServiceBusinessLogic()
        
        print("All tests completed!")
    }
    
    static func testExpenseModel() {
        print("Testing Expense Model...")
        
        let expense = Expense(
            amount: Decimal(29.99),
            description: "Test expense",
            category: .food
        )
        
        assert(expense.amount == Decimal(29.99))
        assert(expense.description == "Test expense")
        assert(expense.category == .food)
        assert(expense.id != UUID())
        
        print("✅ Expense Model tests passed")
    }
    
    static func testCurrencyModel() {
        print("Testing Currency Model...")
        
        let usd = Currency(code: "USD", name: "US Dollar", rate: 1.0)
        let eur = Currency(code: "EUR", name: "Euro", rate: 0.85)
        
        assert(usd.id == "USD")
        assert(usd == Currency(code: "USD", name: "US Dollar", rate: 1.0))
        assert(usd != eur)
        assert(Currency.supportedCurrencies.count > 0)
        
        print("✅ Currency Model tests passed")
    }
    
    static func testAPIService() {
        print("Testing API Service...")
        
        // Test API error descriptions
        let invalidURLError = APIError.invalidURL
        assert(invalidURLError.errorDescription == "Invalid URL")
        
        let serverError = APIError.serverError(404)
        assert(serverError.errorDescription == "Server error with code: 404")
        
        print("✅ API Service tests passed")
    }
    
    static func testExpenseServiceBusinessLogic() {
        print("Testing Expense Service Business Logic...")
        
        // Test currency conversion
        let service = ExpenseServiceCore()
        service.exchangeRates = ["EUR": 0.85, "GBP": 0.75]
        
        let usdAmount = Decimal(100)
        let eurCurrency = Currency(code: "EUR", name: "Euro", rate: 0.85)
        let gbpCurrency = Currency(code: "GBP", name: "British Pound", rate: 0.75)
        
        let eurAmount = service.convertAmount(usdAmount, to: eurCurrency)
        let gbpAmount = service.convertAmount(usdAmount, to: gbpCurrency)
        
        assert(eurAmount == Decimal(85))
        assert(gbpAmount == Decimal(75))
        
        // Test USD conversion (should return same amount)
        let usdCurrency = Currency(code: "USD", name: "US Dollar", rate: 1.0)
        let usdResult = service.convertAmount(usdAmount, to: usdCurrency)
        assert(usdResult == usdAmount)
        
        print("✅ Expense Service Business Logic tests passed")
    }
}

// Core business logic without SwiftUI dependencies
class ExpenseServiceCore {
    var exchangeRates: [String: Double] = [:]
    
    func convertAmount(_ amount: Decimal, to currency: Currency) -> Decimal {
        guard currency.code != "USD" else { return amount }
        
        let rate = exchangeRates[currency.code] ?? currency.rate
        return amount * Decimal(rate)
    }
}