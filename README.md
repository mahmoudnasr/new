# Expense Tracker Lite

A modern iOS expense tracking application built with Clean MVVM architecture, featuring currency conversion, receipt image capture, and real-time data persistence.

## Features

### 🏗️ Clean MVVM Architecture
- **Models**: Domain entities with clean separation of concerns
- **ViewModels**: Business logic with dependency injection and async/await support
- **Views**: Modern SwiftUI interfaces with responsive design
- **Repository Pattern**: Abstracted data layer with protocol-based design

### 💾 CoreData Persistence
- Local storage of all expenses with CoreData
- Pagination support (10 items per page)
- Efficient data fetching with NSPredicate filtering
- Automatic data synchronization

### 💱 Currency Conversion
- Real-time currency conversion using [ExchangeRate-API](https://open.er-api.com/v6/latest/USD)
- Support for 9 major currencies: USD, EUR, GBP, JPY, CAD, AUD, CHF, CNY, INR
- Automatic USD conversion for all expenses
- Offline mock service for testing

### 📱 Modern SwiftUI Interface
- **Dashboard**: Expense list with filter options and pagination
- **Add Expense**: Form with currency selection and image capture
- **Receipt Images**: Camera and photo library integration
- **Filters**: "This Month", "Last 7 Days", and "All" options
- **Pull-to-refresh** and **swipe-to-delete** functionality

### 🧪 Comprehensive Testing
- Unit tests for currency conversion logic
- Core Data operations testing
- Date filtering validation
- Model validation tests
- Performance testing

## Project Structure

```
ExpenseTracker/
├── Models/
│   └── Expense.swift                 # Domain entity with currency support
├── ViewModels/
│   ├── DashboardViewModel.swift      # Dashboard logic with pagination
│   └── AddExpenseViewModel.swift     # Add expense form logic
├── Views/
│   ├── DashboardView.swift           # Main expense dashboard
│   └── AddExpenseView.swift          # Add/edit expense form
├── Repository/
│   └── ExpenseRepository.swift       # Data persistence layer
├── Services/
│   └── CurrencyConverterService.swift # Currency conversion API
├── Persistence/
│   ├── CoreDataStack.swift           # Core Data configuration
│   └── ExpenseModel.xcdatamodeld     # Core Data model
├── Utils/
│   └── DateFilter.swift              # Date filtering utilities
└── Resources/
    └── MockExchangeRates.json        # Test data for currency rates
```

## Technical Implementation

### Currency Conversion
The app automatically converts all expenses to USD using the ExchangeRate-API:
```swift
let convertedAmount = try await currencyService.convertToUSD(
    amount: expense.amount,
    fromCurrency: expense.currency
)
```

### Pagination
Expenses are loaded in paginated chunks for optimal performance:
```swift
func fetchExpenses(page: Int, pageSize: Int = 10) async throws -> [Expense]
```

### Filter System
Date-based filtering with three preset options:
- **This Month**: Current calendar month expenses
- **Last 7 Days**: Rolling 7-day period
- **All**: No date restrictions

### Image Handling
Receipt images are stored as Data in Core Data and displayed efficiently:
```swift
var receiptImage: UIImage? {
    guard let data = receiptImageData else { return nil }
    return UIImage(data: data)
}
```

## Setup & Installation

### Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

### Installation Steps
1. Clone the repository
2. Open `ExpenseTracker.xcodeproj` in Xcode
3. Build and run the project on iOS Simulator or device

### Testing
Run the test suite to verify functionality:
1. In Xcode, press `Cmd+U` to run all tests
2. Tests cover currency conversion, Core Data operations, and date filtering

## API Integration

The app uses the free ExchangeRate-API for currency conversion:
- **Endpoint**: `https://open.er-api.com/v6/latest/USD`
- **Rate Limiting**: No API key required for basic usage
- **Fallback**: Mock service available for offline testing

## Usage

### Adding Expenses
1. Tap the "+" button on the dashboard
2. Enter expense title and amount
3. Select currency from the dropdown
4. Choose date (defaults to today)
5. Optionally add a receipt image
6. Tap "Save Expense"

### Viewing Expenses
1. Use filter buttons to narrow down the list
2. Scroll to see more expenses (automatic pagination)
3. Pull down to refresh the list
4. Swipe left on any expense to delete

### Currency Display
- Original amounts shown in selected currency
- USD converted amounts displayed alongside
- Real-time conversion during expense creation

## Architecture Benefits

### Testability
- Protocol-based design enables easy mocking
- Dependency injection allows isolated testing
- Async/await pattern simplifies test assertions

### Maintainability
- Clear separation of concerns
- Single responsibility principle
- Easy to extend with new features

### Performance
- Efficient pagination reduces memory usage
- CoreData optimizations for large datasets
- Async operations prevent UI blocking

## Future Enhancements

- [ ] Export expenses to CSV/PDF
- [ ] Expense categories and tags
- [ ] Budget tracking and alerts
- [ ] Cloud sync across devices
- [ ] Expense analytics and charts
- [ ] Receipt text recognition (OCR)

## License

This project is available under the MIT license.