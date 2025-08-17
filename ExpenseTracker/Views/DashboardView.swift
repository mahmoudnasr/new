import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with total amount
                headerView
                
                // Filter options
                filterView
                
                // Expenses list
                expensesList
            }
            .navigationTitle("Expense Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .task {
                await viewModel.loadExpenses()
            }
            .refreshable {
                await viewModel.refreshExpenses()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Total Expenses")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(viewModel.formattedTotalAmount)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("\(viewModel.filteredExpensesCount) expenses")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var filterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(DateFilterType.allCases, id: \.self) { filter in
                    FilterButton(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        viewModel.filterExpenses(by: filter)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var expensesList: some View {
        Group {
            if viewModel.isLoading && viewModel.expenses.isEmpty {
                ProgressView("Loading expenses...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.expenses.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.expenses) { expense in
                        ExpenseRowView(expense: expense) {
                            Task {
                                await viewModel.deleteExpense(expense)
                            }
                        }
                        .onAppear {
                            if expense.id == viewModel.expenses.last?.id {
                                Task {
                                    await viewModel.loadMoreExpenses()
                                }
                            }
                        }
                    }
                    
                    if viewModel.isLoading && !viewModel.expenses.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding()
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Expenses Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to add your first expense")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Expense") {
                showingAddExpense = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Receipt image or placeholder
            receiptImageView
            
            // Expense details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(DateFilter.formatDate(expense.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(expense.formattedAmount)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if expense.currency != "USD" {
                        Text("→ \(expense.formattedConvertedAmount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
    }
    
    private var receiptImageView: some View {
        Group {
            if let image = expense.receiptImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "receipt")
                            .foregroundColor(.gray)
                            .font(.title3)
                    )
            }
        }
    }
}

#Preview {
    DashboardView()
}