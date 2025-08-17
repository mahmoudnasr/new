import Foundation
import Combine
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 0
    @Published var hasMorePages = true
    @Published var selectedFilter: DateFilterType = .thisMonth
    @Published var totalAmount: Decimal = 0
    @Published var totalConvertedAmount: Decimal = 0
    
    private let repository: ExpenseRepositoryProtocol
    private let currencyService: CurrencyConverterServiceProtocol
    private let pageSize = 10
    private var cancellables = Set<AnyCancellable>()
    
    init(
        repository: ExpenseRepositoryProtocol = ExpenseRepository(),
        currencyService: CurrencyConverterServiceProtocol = CurrencyConverterService()
    ) {
        self.repository = repository
        self.currencyService = currencyService
        
        setupFilterObserver()
    }
    
    private func setupFilterObserver() {
        $selectedFilter
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.refreshExpenses()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadExpenses() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let newExpenses: [Expense]
            
            if selectedFilter == .all {
                newExpenses = try await repository.fetchExpenses(page: currentPage, pageSize: pageSize)
            } else {
                let dateRange = selectedFilter.dateRange
                newExpenses = try await repository.fetchExpenses(
                    from: dateRange.start,
                    to: dateRange.end,
                    page: currentPage,
                    pageSize: pageSize
                )
            }
            
            if currentPage == 0 {
                expenses = newExpenses
            } else {
                expenses.append(contentsOf: newExpenses)
            }
            
            hasMorePages = newExpenses.count == pageSize
            calculateTotals()
            
            // Update USD conversions for expenses that don't have them
            await updateMissingConversions()
            
        } catch {
            errorMessage = "Failed to load expenses: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refreshExpenses() async {
        currentPage = 0
        hasMorePages = true
        await loadExpenses()
    }
    
    func loadMoreExpenses() async {
        guard hasMorePages && !isLoading else { return }
        
        currentPage += 1
        await loadExpenses()
    }
    
    private func updateMissingConversions() async {
        let expensesNeedingConversion = expenses.filter { $0.convertedAmountUSD == nil && $0.currency != "USD" }
        
        for expense in expensesNeedingConversion {
            do {
                let convertedAmount = try await currencyService.convertToUSD(
                    amount: expense.amount,
                    fromCurrency: expense.currency
                )
                
                var updatedExpense = expense
                updatedExpense.convertedAmountUSD = convertedAmount
                
                try await repository.updateExpense(updatedExpense)
                
                // Update the local array
                if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
                    expenses[index] = updatedExpense
                }
                
            } catch {
                print("Failed to convert currency for expense \(expense.id): \(error)")
            }
        }
        
        calculateTotals()
    }
    
    private func calculateTotals() {
        totalAmount = expenses.reduce(0) { $0 + $1.amount }
        totalConvertedAmount = expenses.reduce(0) { sum, expense in
            sum + (expense.convertedAmountUSD ?? expense.amount)
        }
    }
    
    func deleteExpense(_ expense: Expense) async {
        do {
            try await repository.deleteExpense(id: expense.id)
            expenses.removeAll { $0.id == expense.id }
            calculateTotals()
        } catch {
            errorMessage = "Failed to delete expense: \(error.localizedDescription)"
        }
    }
    
    func filterExpenses(by filter: DateFilterType) {
        selectedFilter = filter
    }
    
    var filteredExpensesCount: Int {
        expenses.count
    }
    
    var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: totalConvertedAmount as NSDecimalNumber) ?? "$\(totalConvertedAmount)"
    }
}