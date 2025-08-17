import Foundation

struct Expense: Identifiable {
    let id = UUID()
    var title: String
    var amount: Double
    var date: Date
}