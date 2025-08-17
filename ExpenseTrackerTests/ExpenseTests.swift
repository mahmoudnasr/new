import XCTest
@testable import ExpenseTracker

final class ExpenseTests: XCTestCase {
    
    var currencyService: MockCurrencyConverterService!
    var repository: ExpenseRepository!
    
    override func setUpWithError() throws {
        currencyService = MockCurrencyConverterService()
        // For testing, we would use an in-memory Core Data stack
        // repository = ExpenseRepository(coreDataStack: TestCoreDataStack())
    }
    
    override func tearDownWithError() throws {
        currencyService = nil
        repository = nil
    }
    
    // MARK: - Currency Conversion Tests
    
    func testCurrencyConversionToUSD() async throws {
        // Test converting EUR to USD
        let amount: Decimal = 100
        let convertedAmount = try await currencyService.convertToUSD(amount: amount, fromCurrency: "EUR")
        
        // Based on mock rate of 0.85 EUR to USD, 100 EUR should be ~117.65 USD
        XCTAssertTrue(convertedAmount > 100, "EUR to USD conversion should result in higher amount")
        XCTAssertEqual(convertedAmount, Decimal(100) / Decimal(0.85), accuracy: 0.01)
    }
    
    func testCurrencyConversionUSDtoUSD() async throws {
        // Test that USD to USD returns the same amount
        let amount: Decimal = 100
        let convertedAmount = try await currencyService.convertToUSD(amount: amount, fromCurrency: "USD")
        
        XCTAssertEqual(convertedAmount, amount)
    }
    
    func testCurrencyConversionWithMultipleCurrencies() async throws {
        let testCases: [(amount: Decimal, currency: String)] = [
            (50, "GBP"),
            (1000, "JPY"),
            (200, "CAD"),
            (75, "AUD")
        ]
        
        for testCase in testCases {
            let convertedAmount = try await currencyService.convertToUSD(
                amount: testCase.amount,
                fromCurrency: testCase.currency
            )
            XCTAssertGreaterThan(convertedAmount, 0, "Converted amount should be positive for \(testCase.currency)")
        }
    }
    
    func testInvalidCurrencyConversion() async {
        do {
            _ = try await currencyService.convertToUSD(amount: 100, fromCurrency: "INVALID")
            XCTFail("Should throw error for invalid currency")
        } catch {
            // Expected to fail
            XCTAssertTrue(error is CurrencyConverterService.CurrencyError)
        }
    }
    
    // MARK: - Expense Model Tests
    
    func testExpenseCreation() {
        let expense = Expense(
            title: "Test Expense",
            amount: 50.99,
            currency: "USD",
            convertedAmountUSD: 50.99,
            date: Date()
        )
        
        XCTAssertNotNil(expense.id)
        XCTAssertEqual(expense.title, "Test Expense")
        XCTAssertEqual(expense.amount, 50.99)
        XCTAssertEqual(expense.currency, "USD")
        XCTAssertEqual(expense.convertedAmountUSD, 50.99)
    }
    
    func testExpenseFormattedAmount() {
        let expense = Expense(
            title: "Test",
            amount: 25.50,
            currency: "USD",
            convertedAmountUSD: 25.50
        )
        
        let formattedAmount = expense.formattedAmount
        XCTAssertTrue(formattedAmount.contains("25.5") || formattedAmount.contains("25.50"))
    }
    
    func testExpenseFormattedConvertedAmount() {
        let expense = Expense(
            title: "Test",
            amount: 100,
            currency: "EUR",
            convertedAmountUSD: 117.65
        )
        
        let formattedConvertedAmount = expense.formattedConvertedAmount
        XCTAssertTrue(formattedConvertedAmount.contains("117.65"))
        XCTAssertTrue(formattedConvertedAmount.contains("$"))
    }
    
    func testExpenseWithReceiptImage() {
        let imageData = Data([0x01, 0x02, 0x03, 0x04]) // Mock image data
        let expense = Expense(
            title: "Test with Receipt",
            amount: 30.00,
            currency: "USD",
            receiptImageData: imageData
        )
        
        XCTAssertEqual(expense.receiptImageData, imageData)
        XCTAssertNotNil(expense.receiptImageData)
    }
    
    // MARK: - Date Filter Tests
    
    func testDateFilterThisMonth() {
        let filter = DateFilterType.thisMonth
        let dateRange = filter.dateRange
        
        let calendar = Calendar.current
        let now = Date()
        
        let isStartOfMonth = calendar.isDate(dateRange.start, inSameDayAs: calendar.dateInterval(of: .month, for: now)?.start ?? now)
        XCTAssertTrue(isStartOfMonth || abs(dateRange.start.timeIntervalSince(calendar.dateInterval(of: .month, for: now)?.start ?? now)) < 86400) // Within a day
    }
    
    func testDateFilterLastSevenDays() {
        let filter = DateFilterType.lastSevenDays
        let dateRange = filter.dateRange
        
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        let daysBetween = calendar.dateComponents([.day], from: dateRange.start, to: now).day ?? 0
        XCTAssertTrue(daysBetween >= 6 && daysBetween <= 8) // Allow some tolerance
    }
    
    func testDateFilterFormatting() {
        let date = Date()
        let formattedDate = DateFilter.formatDate(date)
        
        XCTAssertFalse(formattedDate.isEmpty)
        XCTAssertTrue(formattedDate.count > 5) // Should be a meaningful date string
    }
    
    func testIsInCurrentMonth() {
        let now = Date()
        XCTAssertTrue(DateFilter.isInCurrentMonth(now))
        
        let calendar = Calendar.current
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        XCTAssertFalse(DateFilter.isInCurrentMonth(lastMonth))
    }
    
    func testIsInLastSevenDays() {
        let now = Date()
        XCTAssertTrue(DateFilter.isInLastSevenDays(now))
        
        let calendar = Calendar.current
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: now) ?? now
        XCTAssertTrue(DateFilter.isInLastSevenDays(fiveDaysAgo))
        
        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: now) ?? now
        XCTAssertFalse(DateFilter.isInLastSevenDays(tenDaysAgo))
    }
    
    // MARK: - Currency Enum Tests
    
    func testCurrencySymbols() {
        XCTAssertEqual(Currency.usd.symbol, "$")
        XCTAssertEqual(Currency.eur.symbol, "€")
        XCTAssertEqual(Currency.gbp.symbol, "£")
        XCTAssertEqual(Currency.jpy.symbol, "¥")
    }
    
    func testCurrencyAllCases() {
        let allCurrencies = Currency.allCases
        XCTAssertTrue(allCurrencies.contains(.usd))
        XCTAssertTrue(allCurrencies.contains(.eur))
        XCTAssertTrue(allCurrencies.contains(.gbp))
        XCTAssertTrue(allCurrencies.count >= 9) // At least 9 currencies defined
    }
    
    // MARK: - Performance Tests
    
    func testCurrencyConversionPerformance() throws {
        measure {
            Task {
                do {
                    _ = try await currencyService.convertToUSD(amount: 100, fromCurrency: "EUR")
                } catch {
                    // Handle error in performance test
                }
            }
        }
    }
}