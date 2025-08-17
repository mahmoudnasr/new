import Foundation
import SwiftUI

struct Expense: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Decimal
    var currency: String
    var convertedAmountUSD: Decimal?
    var date: Date
    var receiptImageData: Data?
    
    init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        currency: String,
        convertedAmountUSD: Decimal? = nil,
        date: Date = Date(),
        receiptImageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currency = currency
        self.convertedAmountUSD = convertedAmountUSD
        self.date = date
        self.receiptImageData = receiptImageData
    }
}

enum ExpenseCategory: String, CaseIterable {
    case food = "Food"
    case transportation = "Transportation"
    case entertainment = "Entertainment"
    case utilities = "Utilities"
    case shopping = "Shopping"
    case health = "Health"
    case other = "Other"
}

extension Expense {
    static var preview: Expense {
        Expense(
            title: "Lunch with colleagues",
            amount: 29.99,
            currency: Currency.usd.rawValue,
            convertedAmountUSD: 29.99,
            date: Date()
        )
    }
    
    var receiptImage: UIImage? {
        guard let data = receiptImageData else { return nil }
        return UIImage(data: data)
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
    
    var formattedConvertedAmount: String {
        guard let convertedAmount = convertedAmountUSD else { return "Converting..." }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: convertedAmount as NSDecimalNumber) ?? "$\(convertedAmount)"
    }
}