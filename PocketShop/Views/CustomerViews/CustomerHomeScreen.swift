import SwiftUI

struct CustomerHomeScreen: View {
    @StateObject var viewModel = CustomerViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Products")
                    .font(.appTitle)
                    .foregroundColor(.gray9)

                PSSearchBarView(searchText: $viewModel.searchText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.productSearchResults, id: \.self) { product in
                            NavigationLink(destination: ProductView(product: product)) {
                                ProductSummaryView(product: product)
                            }
                        }
                    }
                }
                .navigationTitle("Home")
                .font(.appHeadline)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomerSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerHomeScreen()
    }
}
