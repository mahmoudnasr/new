import Foundation
import Combine

protocol APIServiceProtocol {
    func fetchExchangeRates() async throws -> ExchangeRateResponse
}

class APIService: APIServiceProtocol {
    private let baseURL = "https://open.er-api.com/v6/latest/USD"
    private let session = URLSession.shared
    
    func fetchExchangeRates() async throws -> ExchangeRateResponse {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let exchangeRateResponse = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            
            guard exchangeRateResponse.result == "success" else {
                throw APIError.apiError(exchangeRateResponse.result)
            }
            
            return exchangeRateResponse
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case apiError(String)
    case decodingError(DecodingError)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}