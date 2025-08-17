import XCTest
@testable import ExpenseTracker

final class ExpenseServiceTests: XCTestCase {
    var expenseService: ExpenseService!
    var mockAPIService: MockAPIService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        expenseService = ExpenseService(apiService: mockAPIService)
    }
    
    override func tearDown() {
        expenseService = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    func testAddExpense() {
        // Given
        let expense = Expense(
            amount: Decimal(50.0),
            description: "Test expense",
            category: .food
        )
        let initialCount = expenseService.expenses.count
        
        // When
        expenseService.addExpense(expense)
        
        // Then
        XCTAssertEqual(expenseService.expenses.count, initialCount + 1)
        XCTAssertTrue(expenseService.expenses.contains { $0.id == expense.id })
    }
    
    func testRemoveExpense() {
        // Given
        let expense = Expense(
            amount: Decimal(50.0),
            description: "Test expense",
            category: .food
        )
        expenseService.addExpense(expense)
        let initialCount = expenseService.expenses.count
        
        // When
        expenseService.removeExpense(expense)
        
        // Then
        XCTAssertEqual(expenseService.expenses.count, initialCount - 1)
        XCTAssertFalse(expenseService.expenses.contains { $0.id == expense.id })
    }
    
    func testCurrencyConversion() {
        // Given
        let amount = Decimal(100.0)
        let eurCurrency = Currency(code: "EUR", name: "Euro", rate: 0.85)
        expenseService.exchangeRates = ["EUR": 0.85]
        
        // When
        let convertedAmount = expenseService.convertAmount(amount, to: eurCurrency)
        
        // Then
        XCTAssertEqual(convertedAmount, Decimal(85.0))
    }
    
    func testCurrencyConversionUSD() {
        // Given
        let amount = Decimal(100.0)
        let usdCurrency = Currency(code: "USD", name: "US Dollar", rate: 1.0)
        
        // When
        let convertedAmount = expenseService.convertAmount(amount, to: usdCurrency)
        
        // Then
        XCTAssertEqual(convertedAmount, amount)
    }
    
    func testSelectCurrency() {
        // Given
        let eurCurrency = Currency(code: "EUR", name: "Euro", rate: 0.85)
        
        // When
        expenseService.selectCurrency(eurCurrency)
        
        // Then
        XCTAssertEqual(expenseService.selectedCurrency, eurCurrency)
    }
    
    func testFetchExchangeRatesSuccess() async {
        // Given
        let mockResponse = ExchangeRateResponse(
            result: "success",
            documentation: "test",
            termsOfUse: "test",
            timeLastUpdateUnix: 1234567890,
            timeLastUpdateUTC: "test",
            timeNextUpdateUnix: 1234567890,
            timeNextUpdateUTC: "test",
            baseCode: "USD",
            rates: ["EUR": 0.85, "GBP": 0.75]
        )
        mockAPIService.mockResponse = mockResponse
        
        // When
        await expenseService.fetchExchangeRates()
        
        // Then
        XCTAssertEqual(expenseService.exchangeRates["EUR"], 0.85)
        XCTAssertEqual(expenseService.exchangeRates["GBP"], 0.75)
        XCTAssertFalse(expenseService.isLoading)
        XCTAssertNil(expenseService.errorMessage)
    }
    
    func testFetchExchangeRatesFailure() async {
        // Given
        mockAPIService.shouldFail = true
        
        // When
        await expenseService.fetchExchangeRates()
        
        // Then
        XCTAssertFalse(expenseService.isLoading)
        XCTAssertNotNil(expenseService.errorMessage)
    }
}

class MockAPIService: APIServiceProtocol {
    var mockResponse: ExchangeRateResponse?
    var shouldFail = false
    
    func fetchExchangeRates() async throws -> ExchangeRateResponse {
        if shouldFail {
            throw APIError.networkError(NSError(domain: "test", code: 0, userInfo: nil))
        }
        
        guard let response = mockResponse else {
            throw APIError.invalidResponse
        }
        
        return response
    }
}