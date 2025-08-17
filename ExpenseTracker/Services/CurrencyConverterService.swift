import Foundation
import Combine

protocol CurrencyConverterServiceProtocol {
    func convertToUSD(amount: Decimal, fromCurrency: String) async throws -> Decimal
    func getExchangeRate(from: String, to: String) async throws -> Decimal
}

class CurrencyConverterService: CurrencyConverterServiceProtocol {
    private let baseURL = "https://open.er-api.com/v6/latest"
    private let session = URLSession.shared
    
    enum CurrencyError: Error {
        case invalidURL
        case noData
        case decodingError
        case networkError(Error)
        case unsupportedCurrency
        case invalidResponse
    }
    
    private struct ExchangeRateResponse: Codable {
        let result: String
        let base_code: String
        let rates: [String: Double]
    }
    
    func convertToUSD(amount: Decimal, fromCurrency: String) async throws -> Decimal {
        // If already USD, return original amount
        if fromCurrency.uppercased() == "USD" {
            return amount
        }
        
        let exchangeRate = try await getExchangeRate(from: fromCurrency, to: "USD")
        return amount * exchangeRate
    }
    
    func getExchangeRate(from: String, to: String) async throws -> Decimal {
        guard let url = URL(string: "\(baseURL)/\(from.uppercased())") else {
            throw CurrencyError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw CurrencyError.invalidResponse
            }
            
            let exchangeResponse = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            
            guard let rate = exchangeResponse.rates[to.uppercased()] else {
                throw CurrencyError.unsupportedCurrency
            }
            
            return Decimal(rate)
            
        } catch let error as DecodingError {
            throw CurrencyError.decodingError
        } catch {
            throw CurrencyError.networkError(error)
        }
    }
}

// MARK: - Mock Service for Testing
class MockCurrencyConverterService: CurrencyConverterServiceProtocol {
    private let mockRates: [String: Decimal] = [
        "EUR": 0.85,
        "GBP": 0.73,
        "JPY": 110.0,
        "CAD": 1.25,
        "AUD": 1.35,
        "CHF": 0.92,
        "CNY": 6.45,
        "INR": 74.5
    ]
    
    func convertToUSD(amount: Decimal, fromCurrency: String) async throws -> Decimal {
        if fromCurrency.uppercased() == "USD" {
            return amount
        }
        
        let exchangeRate = try await getExchangeRate(from: fromCurrency, to: "USD")
        return amount * exchangeRate
    }
    
    func getExchangeRate(from: String, to: String) async throws -> Decimal {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        if from.uppercased() == "USD" && to.uppercased() == "USD" {
            return 1.0
        }
        
        if from.uppercased() == "USD" {
            guard let rate = mockRates[to.uppercased()] else {
                throw CurrencyConverterService.CurrencyError.unsupportedCurrency
            }
            return rate
        }
        
        if to.uppercased() == "USD" {
            guard let rate = mockRates[from.uppercased()] else {
                throw CurrencyConverterService.CurrencyError.unsupportedCurrency
            }
            return 1 / rate
        }
        
        // For other currency pairs, convert through USD
        guard let fromRate = mockRates[from.uppercased()],
              let toRate = mockRates[to.uppercased()] else {
            throw CurrencyConverterService.CurrencyError.unsupportedCurrency
        }
        
        return toRate / fromRate
    }
}