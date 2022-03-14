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

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.productSearchResults, id: \.self) { product in
                            NavigationLink(destination: ProductView(product: product)) {
                                ProductSummaryView(product: product)
                            }
                        }
                    }
                }
                .searchable(text: $viewModel.searchText)
                .navigationTitle("Home")
            }
        }
    }
}

struct CustomerSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerHomeView()
    }
}
