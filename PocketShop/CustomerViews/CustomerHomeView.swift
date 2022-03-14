import SwiftUI

struct CustomerHomeView: View {
    @StateObject var viewModel = CustomerViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Products")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)

                SearchBarView(searchText: $viewModel.searchText)

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
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomerSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerHomeView()
    }
}
