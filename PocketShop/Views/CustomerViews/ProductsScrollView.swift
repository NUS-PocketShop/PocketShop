import SwiftUI

struct ProductsScrollView: View {
    @StateObject var viewModel: CustomerViewModel

    var body: some View {
        VStack {
            Text("Products")
                .font(.appTitle)
                .foregroundColor(.gray9)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.productSearchResults, id: \.self) { product in
                        NavigationLink(destination: ProductView(product: product)) {
                            ProductSummaryView(product: product)
                        }
                    }
                }
            }
        }
    }
}

struct ProductsScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsScrollView(viewModel: CustomerViewModel())
    }
}
