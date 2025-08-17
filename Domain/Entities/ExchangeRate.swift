import Foundation

struct ExchangeRateResponse: Codable {
    let result: String
    let documentation: String
    let termsOfUse: String
    let timeLastUpdateUnix: Int
    let timeLastUpdateUTC: String
    let timeNextUpdateUnix: Int
    let timeNextUpdateUTC: String
    let baseCode: String
    let rates: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case result, documentation
        case termsOfUse = "terms_of_use"
        case timeLastUpdateUnix = "time_last_update_unix"
        case timeLastUpdateUTC = "time_last_update_utc"
        case timeNextUpdateUnix = "time_next_update_unix"
        case timeNextUpdateUTC = "time_next_update_utc"
        case baseCode = "base_code"
        case rates
    }
}

struct Currency {
    let code: String
    let name: String
    let rate: Double
    
    static let supportedCurrencies: [Currency] = [
        Currency(code: "USD", name: "US Dollar", rate: 1.0),
        Currency(code: "EUR", name: "Euro", rate: 0.85),
        Currency(code: "GBP", name: "British Pound", rate: 0.75),
        Currency(code: "JPY", name: "Japanese Yen", rate: 110.0),
        Currency(code: "CAD", name: "Canadian Dollar", rate: 1.25),
        Currency(code: "AUD", name: "Australian Dollar", rate: 1.35),
        Currency(code: "CHF", name: "Swiss Franc", rate: 0.92),
        Currency(code: "CNY", name: "Chinese Yuan", rate: 6.45)
    ]
}

extension Currency: Identifiable {
    var id: String { code }
}

extension Currency: Equatable {
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        lhs.code == rhs.code
    }
}