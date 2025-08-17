# Expense Tracker Lite

This is an enhanced iOS app built using SwiftUI that allows users to track their daily expenses with multi-currency support and real-time exchange rates.

## Features

### Core Features
- Add new expenses with description, amount, category, and date
- View all expenses in a list with currency conversion
- Simple and clean user interface
- Category-based expense organization

### New Currency Features ✨
- **Multi-currency support** with 8 major currencies (USD, EUR, GBP, JPY, CAD, AUD, CHF, CNY)
- **Real-time exchange rates** from [ExchangeRate-API](https://open.er-api.com/)
- **Currency conversion** for all expenses with precise decimal calculations
- **Currency selector** with intuitive UI
- **Automatic rate refresh** with error handling and loading states

## Architecture

The app follows clean architecture principles with clear separation of concerns:

### Domain Layer
- **Entities**: Core business models (`Expense`, `Currency`, `ExchangeRateResponse`)
  - Located in `/Domain/Entities/`

### Service Layer
- **APIService**: Handles exchange rate API calls with comprehensive error handling
- **ExpenseService**: Manages app state, business logic, and currency conversions
  - Located in `/Services/`

### Presentation Layer
- **Views**: SwiftUI views with proper state management
  - Main views: `ExpenseListView`, `AddExpenseView`, `CurrencySelectorView`
  - Located in `/Views/` and root directory

### State Management
- Uses `@StateObject` and `@EnvironmentObject` for application-wide state
- Reactive UI updates with `@Published` properties
- Async/await pattern for API calls

## Requirements
- iOS 15.0+
- Xcode 13+
- Internet connection for exchange rate updates

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/mahmoudnasr/new.git
   ```
2. Open `new.xcodeproj` in Xcode (when available)
3. Build and run the project on your simulator or device

## Usage

### Adding Expenses
1. Tap the "+" button in the top-right corner
2. Enter expense description, amount (in USD), category, and date
3. Tap "Save" to add the expense

### Currency Conversion
1. Tap the currency code in the top-left corner (defaults to "USD")
2. Select your preferred currency from the list
3. All expenses will automatically convert and display in the selected currency
4. Tap the refresh button (↻) to update exchange rates

### Categories
Expenses can be categorized as:
- Food, Transportation, Entertainment
- Utilities, Shopping, Health, Other

## API Integration

The app integrates with the ExchangeRate-API (https://open.er-api.com/v6/latest/USD) to provide:
- Real-time exchange rates for all supported currencies
- Robust error handling for network issues
- Fallback rates for offline functionality

## Testing

The project includes comprehensive unit tests:
- **ExpenseServiceTests**: Business logic, currency conversion, state management
- **APIServiceTests**: API integration, error handling, data parsing
- Located in `/Tests/`

Run tests in Xcode with `Cmd+U` or use Swift Package Manager.

## License
This project is licensed under the MIT License - see the LICENSE file for details.