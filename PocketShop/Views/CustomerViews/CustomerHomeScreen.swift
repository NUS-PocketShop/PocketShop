import SwiftUI

struct CustomerHomeScreen: View {
    @StateObject var viewModel = CustomerViewModel()

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                PSSearchBarView(searchText: $viewModel.searchText)
                ProductsScrollView(viewModel: viewModel)
                ShopsScrollView(viewModel: viewModel)
            }
            .navigationTitle("Home")
            .font(.appHeadline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomerSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerHomeScreen()
    }
}
