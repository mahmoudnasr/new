import XCTest
@testable import ExpenseTracker

final class APIServiceTests: XCTestCase {
    var apiService: APIService!
    
    override func setUp() {
        super.setUp()
        apiService = APIService()
    }
    
    override func tearDown() {
        apiService = nil
        super.tearDown()
    }
    
    // Note: This test requires network access and tests the real API
    // In a production app, we would use mock URL sessions
    func testFetchExchangeRatesIntegration() async throws {
        // When
        let response = try await apiService.fetchExchangeRates()
        
        // Then
        XCTAssertEqual(response.result, "success")
        XCTAssertEqual(response.baseCode, "USD")
        XCTAssertFalse(response.rates.isEmpty)
        XCTAssertNotNil(response.rates["EUR"])
        XCTAssertNotNil(response.rates["GBP"])
    }
}

final class ExchangeRateModelTests: XCTestCase {
    func testExchangeRateResponseDecoding() throws {
        // Given
        let json = """
        {
            "result": "success",
            "documentation": "https://www.exchangerate-api.com/docs",
            "terms_of_use": "https://www.exchangerate-api.com/terms",
            "time_last_update_unix": 1585267200,
            "time_last_update_utc": "Sat, 28 Mar 2020 00:00:00 +0000",
            "time_next_update_unix": 1585353600,
            "time_next_update_utc": "Sun, 29 Mar 2020 00:00:00 +0000",
            "base_code": "USD",
            "rates": {
                "EUR": 0.85,
                "GBP": 0.75,
                "JPY": 110.0
            }
        }
        """.data(using: .utf8)!
        
        // When
        let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: json)
        
        // Then
        XCTAssertEqual(response.result, "success")
        XCTAssertEqual(response.baseCode, "USD")
        XCTAssertEqual(response.rates["EUR"], 0.85)
        XCTAssertEqual(response.rates["GBP"], 0.75)
        XCTAssertEqual(response.rates["JPY"], 110.0)
    }
    
    func testCurrencyEquality() {
        // Given
        let currency1 = Currency(code: "USD", name: "US Dollar", rate: 1.0)
        let currency2 = Currency(code: "USD", name: "US Dollar", rate: 1.0)
        let currency3 = Currency(code: "EUR", name: "Euro", rate: 0.85)
        
        // Then
        XCTAssertEqual(currency1, currency2)
        XCTAssertNotEqual(currency1, currency3)
    }
    
    func testCurrencyIdentifiable() {
        // Given
        let currency = Currency(code: "USD", name: "US Dollar", rate: 1.0)
        
        // Then
        XCTAssertEqual(currency.id, "USD")
    }
    
    func testSupportedCurrencies() {
        // Given
        let supportedCurrencies = Currency.supportedCurrencies
        
        // Then
        XCTAssertFalse(supportedCurrencies.isEmpty)
        XCTAssertTrue(supportedCurrencies.contains { $0.code == "USD" })
        XCTAssertTrue(supportedCurrencies.contains { $0.code == "EUR" })
        XCTAssertTrue(supportedCurrencies.contains { $0.code == "GBP" })
    }
}