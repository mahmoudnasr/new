import SwiftUI

struct ContentView: View {
    @StateObject private var expenseService = ExpenseService()
    
    var body: some View {
        NavigationView {
            ExpenseListView()
        }
        .environmentObject(expenseService)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}