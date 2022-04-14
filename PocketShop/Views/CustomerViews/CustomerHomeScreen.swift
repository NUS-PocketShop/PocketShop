import SwiftUI

struct CustomerHomeScreen: View {
    @EnvironmentObject var viewModel: CustomerViewModel

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                PSSearchBarView(searchText: $viewModel.searchText)
                ProductsScrollView(productsToShow: viewModel.productSearchResults)
                ShopsScrollView()
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
