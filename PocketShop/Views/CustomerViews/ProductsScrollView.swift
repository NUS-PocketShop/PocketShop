import SwiftUI

struct ProductsScrollView: View {
    @EnvironmentObject var viewModel: CustomerViewModel

    var body: some View {
        VStack {
            if !viewModel.productSearchResults.isEmpty {
                Text("Products")
                    .font(.appTitle)
                    .foregroundColor(.gray9)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.productSearchResults) { product in
                        NavigationLink(destination: ProductView(product: product)
                                        .environmentObject(viewModel)) {
                            ProductSummaryView(product: product)
                                .environmentObject(viewModel)
                        }
                    }
                }
            }
        }
    }
}

struct ProductsScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsScrollView().environmentObject(CustomerViewModel())
    }
}
