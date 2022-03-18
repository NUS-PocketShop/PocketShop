import SwiftUI

struct CustomerHomeScreen: View {
    @StateObject var viewModel = CustomerViewModel()

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                SearchBarView(searchText: $viewModel.searchText)
                ProductsScrollView(viewModel: viewModel)
                ShopsScrollView(viewModel: viewModel)
            }
            .navigationTitle("Home")
            .font(.appHeadline)
            .navigationViewStyle(.stack)
        }
    }
}

struct CustomerSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerHomeScreen()
    }
}
