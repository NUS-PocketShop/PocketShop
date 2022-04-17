import SwiftUI

struct ProductDetailView: View {
    var product: Product
    var cartProduct: CartProduct?

    init(product: Product) {
        self.product = product
    }

    init(product: Product, cartProduct: CartProduct) {
        self.product = product
        self.cartProduct = cartProduct
    }

    var body: some View {
        VStack {
            NameLocationSection(product: product)

            URLImage(urlString: product.imageURL)
                .scaledToFit()
                .frame(width: 150, height: 150) // Might change to relative sizes

            DescriptionSection(product: product)

            ProductOrderBar(product: product, cartProduct: cartProduct)
        }
        .toolbar {
            FavouritesButton(itemId: product.id)
        }
    }
}

private struct NameLocationSection: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var product: Product

    var location: String {
        "\(product.shopName) (\(viewModel.getLocationNameFromProduct(product: product)))"
    }

    var body: some View {
        VStack {
            Text(product.name)
                .font(.appTitle)

            Text(location)
                .font(.appHeadline)
                .foregroundColor(.gray6)
        }
    }
}

private struct FavouritesButton: View {
    @EnvironmentObject var viewModel: CustomerViewModel

    var itemId: ID

    var body: some View {
        Button(action: {
            viewModel.toggleProductAsFavorites(productId: itemId)
        }, label: {
            if viewModel.favourites.contains(where: { $0.id == itemId }) {
                Image(systemName: "heart.fill")
            } else {
                Image(systemName: "heart")
            }
        })
    }
}

private struct DescriptionSection: View {
    @EnvironmentObject var viewModel: CustomerViewModel

    var product: Product
    @State var subproducts: [Product] = []

    var body: some View {
        VStack {
            Text(product.description)
                .font(.appBody)

            if product.isComboMeal {
                Text("Combo consists of: \(subproducts.map({ $0.name }).joined(separator: ", "))")
                    .font(.appBody)
            }
        }.onAppear {
            subproducts = product.subProductIds.compactMap {
                    viewModel.getProductFromProductId(productId: $0)
            }
        }
        .padding(.vertical)
    }

}

// MARK: Preview
struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProduct = CustomerViewModel().products.first!
        ProductDetailView(product: sampleProduct).environmentObject(CustomerViewModel())
    }
}
