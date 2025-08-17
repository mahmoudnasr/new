import Foundation

struct Expense: Identifiable {
    let id: UUID
    var amount: Decimal
    var description: String
    var category: ExpenseCategory
    var date: Date
    
    init(
        id: UUID = UUID(),
        amount: Decimal,
        description: String,
        category: ExpenseCategory,
        date: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.description = description
        self.category = category
        self.date = date
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
            amount: 29.99,
            description: "Lunch with colleagues",
            category: .food
        )
    }
}