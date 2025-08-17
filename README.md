# SwiftUI Clean Architecture with MVVM

A SwiftUI application implementing Clean Architecture with MVVM pattern, using CoreData for persistence.

## Project Structure

```
SwiftUICleanMVVM/
├── App/
│   ├── SwiftUICleanMVVMApp.swift
│   └── ContentView.swift
├── Domain/
│   ├── Entities/
│   │   └── Expense.swift
│   ├── Interfaces/
│   │   └── ExpenseRepository.swift
│   └── UseCases/
│       └── ExpenseUseCases.swift
├── Data/
│   ├── CoreData/
│   │   ├── CoreDataStack.swift
│   │   └── ExpenseModel.xcdatamodeld
│   └── Repositories/
│       └── CoreDataExpenseRepository.swift
└── Presentation/
    ├── ViewModels/
    │   └── ExpenseViewModel.swift
    └── Views/
        ├── ExpenseListView.swift
        └── AddExpenseView.swift
```

## Architecture

This project follows Clean Architecture principles with MVVM pattern:

1. **Domain Layer**: Contains business logic and rules
   - Entities
   - Repository Interfaces
   - Use Cases

2. **Data Layer**: Handles data operations
   - CoreData Implementation
   - Repository Implementation

3. **Presentation Layer**: UI and user interactions
   - ViewModels
   - SwiftUI Views

## Features

- [x] Add new expenses
- [x] List all expenses
- [x] Delete expenses
- [x] Persistence with CoreData
- [x] Error handling
- [x] Category management
- [x] Sort by date

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
2. Open SwiftUICleanMVVM.xcodeproj
3. Build and run the project

## License

This project is available under the MIT license.