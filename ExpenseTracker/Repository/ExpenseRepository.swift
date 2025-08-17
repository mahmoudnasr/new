import Foundation
import CoreData
import Combine

protocol ExpenseRepositoryProtocol {
    func fetchExpenses(page: Int, pageSize: Int) async throws -> [Expense]
    func addExpense(_ expense: Expense) async throws
    func updateExpense(_ expense: Expense) async throws
    func deleteExpense(id: UUID) async throws
    func getExpenseCount() async throws -> Int
    func fetchExpenses(from startDate: Date, to endDate: Date, page: Int, pageSize: Int) async throws -> [Expense]
}

class ExpenseRepository: ExpenseRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchExpenses(page: Int, pageSize: Int) async throws -> [Expense] {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.context
            context.perform {
                do {
                    let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
                    request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)]
                    request.fetchLimit = pageSize
                    request.fetchOffset = page * pageSize
                    
                    let entities = try context.fetch(request)
                    let expenses = entities.map { $0.toExpense() }
                    continuation.resume(returning: expenses)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func addExpense(_ expense: Expense) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.context
            context.perform {
                do {
                    let entity = ExpenseEntity(context: context)
                    entity.update(from: expense)
                    try context.save()
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func updateExpense(_ expense: Expense) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.context
            context.perform {
                do {
                    let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
                    
                    let entities = try context.fetch(request)
                    guard let entity = entities.first else {
                        throw RepositoryError.expenseNotFound
                    }
                    
                    entity.update(from: expense)
                    try context.save()
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func deleteExpense(id: UUID) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.context
            context.perform {
                do {
                    let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                    
                    let entities = try context.fetch(request)
                    guard let entity = entities.first else {
                        throw RepositoryError.expenseNotFound
                    }
                    
                    context.delete(entity)
                    try context.save()
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getExpenseCount() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.context
            context.perform {
                do {
                    let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
                    let count = try context.count(for: request)
                    continuation.resume(returning: count)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func fetchExpenses(from startDate: Date, to endDate: Date, page: Int, pageSize: Int) async throws -> [Expense] {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.context
            context.perform {
                do {
                    let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
                    request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)]
                    request.fetchLimit = pageSize
                    request.fetchOffset = page * pageSize
                    
                    let entities = try context.fetch(request)
                    let expenses = entities.map { $0.toExpense() }
                    continuation.resume(returning: expenses)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

enum RepositoryError: Error {
    case expenseNotFound
    case coreDataError(Error)
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .expenseNotFound:
            return "Expense not found"
        case .coreDataError(let error):
            return "Core Data error: \(error.localizedDescription)"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}