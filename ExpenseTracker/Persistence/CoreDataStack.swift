import CoreData
import Foundation

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ExpenseModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}

// MARK: - Core Data Entity
@objc(ExpenseEntity)
public class ExpenseEntity: NSManagedObject {
    
}

extension ExpenseEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseEntity> {
        return NSFetchRequest<ExpenseEntity>(entityName: "ExpenseEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var currency: String
    @NSManaged public var convertedAmountUSD: NSDecimalNumber?
    @NSManaged public var date: Date
    @NSManaged public var receiptImageData: Data?
}

extension ExpenseEntity: Identifiable {
    
}

// MARK: - Conversion Extensions
extension ExpenseEntity {
    func toExpense() -> Expense {
        return Expense(
            id: self.id,
            title: self.title,
            amount: self.amount.decimalValue,
            currency: self.currency,
            convertedAmountUSD: self.convertedAmountUSD?.decimalValue,
            date: self.date,
            receiptImageData: self.receiptImageData
        )
    }
    
    func update(from expense: Expense) {
        self.id = expense.id
        self.title = expense.title
        self.amount = NSDecimalNumber(decimal: expense.amount)
        self.currency = expense.currency
        self.convertedAmountUSD = expense.convertedAmountUSD.map { NSDecimalNumber(decimal: $0) }
        self.date = expense.date
        self.receiptImageData = expense.receiptImageData
    }
}