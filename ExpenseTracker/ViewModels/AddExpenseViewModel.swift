import Foundation
import Combine
import SwiftUI
import PhotosUI

@MainActor
class AddExpenseViewModel: ObservableObject {
    @Published var title = ""
    @Published var amount = ""
    @Published var selectedCurrency: Currency = .usd
    @Published var date = Date()
    @Published var receiptImage: UIImage?
    @Published var receiptImageData: Data?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var convertedAmountUSD: Decimal?
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    
    private let repository: ExpenseRepositoryProtocol
    private let currencyService: CurrencyConverterServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        repository: ExpenseRepositoryProtocol = ExpenseRepository(),
        currencyService: CurrencyConverterServiceProtocol = CurrencyConverterService()
    ) {
        self.repository = repository
        self.currencyService = currencyService
        
        setupCurrencyConversionObserver()
    }
    
    private func setupCurrencyConversionObserver() {
        Publishers.CombineLatest($amount, $selectedCurrency)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] amount, currency in
                Task { @MainActor in
                    await self?.updateCurrencyConversion(amount: amount, currency: currency)
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateCurrencyConversion(amount: String, currency: Currency) async {
        guard !amount.isEmpty,
              let decimalAmount = Decimal(string: amount),
              decimalAmount > 0 else {
            convertedAmountUSD = nil
            return
        }
        
        if currency == .usd {
            convertedAmountUSD = decimalAmount
            return
        }
        
        do {
            convertedAmountUSD = try await currencyService.convertToUSD(
                amount: decimalAmount,
                fromCurrency: currency.rawValue
            )
        } catch {
            print("Failed to convert currency: \(error)")
            convertedAmountUSD = nil
        }
    }
    
    func saveExpense() async -> Bool {
        guard isValidInput() else {
            return false
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            guard let decimalAmount = Decimal(string: amount) else {
                errorMessage = "Invalid amount"
                isLoading = false
                return false
            }
            
            let expense = Expense(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: decimalAmount,
                currency: selectedCurrency.rawValue,
                convertedAmountUSD: convertedAmountUSD,
                date: date,
                receiptImageData: receiptImageData
            )
            
            try await repository.addExpense(expense)
            
            successMessage = "Expense added successfully!"
            clearForm()
            isLoading = false
            return true
            
        } catch {
            errorMessage = "Failed to save expense: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    private func isValidInput() -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedTitle.isEmpty {
            errorMessage = "Please enter a title"
            return false
        }
        
        if amount.isEmpty {
            errorMessage = "Please enter an amount"
            return false
        }
        
        guard let decimalAmount = Decimal(string: amount), decimalAmount > 0 else {
            errorMessage = "Please enter a valid amount greater than 0"
            return false
        }
        
        return true
    }
    
    func clearForm() {
        title = ""
        amount = ""
        selectedCurrency = .usd
        date = Date()
        receiptImage = nil
        receiptImageData = nil
        convertedAmountUSD = nil
        errorMessage = nil
        successMessage = nil
    }
    
    func selectImage(_ image: UIImage) {
        receiptImage = image
        receiptImageData = image.jpegData(compressionQuality: 0.8)
    }
    
    func removeReceiptImage() {
        receiptImage = nil
        receiptImageData = nil
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !amount.isEmpty &&
        Decimal(string: amount) ?? 0 > 0
    }
    
    var formattedConvertedAmount: String {
        guard let convertedAmount = convertedAmountUSD else {
            return selectedCurrency == .usd ? "" : "Converting..."
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: convertedAmount as NSDecimalNumber) ?? "$\(convertedAmount)"
    }
    
    var formattedAmount: String {
        guard !amount.isEmpty, let decimalAmount = Decimal(string: amount) else {
            return ""
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency.rawValue
        return formatter.string(from: decimalAmount as NSDecimalNumber) ?? "\(selectedCurrency.symbol)\(decimalAmount)"
    }
}