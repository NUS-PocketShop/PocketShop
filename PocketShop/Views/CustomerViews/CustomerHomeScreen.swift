import SwiftUI

struct CustomerHomeScreen: View {
    @StateObject var viewModel = CustomerViewModel()

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                PSSearchBarView(searchText: $viewModel.searchText)
                ProductsScrollView()
                ShopsScrollView()
                LocationsScrollView()
            }
            .navigationTitle("Home")
            .font(.appHeadline)
        }
        .environmentObject(viewModel)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomerSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerHomeScreen()
    }
}
