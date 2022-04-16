import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var viewModel: CustomerViewModel
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

            Text(product.description)
                .font(.appBody)
                .padding(.vertical)

            if product.isComboMeal {
                Text("""
                    Combo meal of: \(product.subProductIds.map({ $0.description })
                                        .joined(separator: ", "))
                    """)
            }

            Text(String(format: "$%.2f", product.price))
                .font(.appBody)
                .fontWeight(.semibold)

            ProductOrderBar(product: product, cartProduct: cartProduct)
        }
        .toolbar {
            FavouritesButton(itemId: product.id)
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProduct = CustomerViewModel().products.first!
        ProductDetailView(product: sampleProduct).environmentObject(CustomerViewModel())
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
            Text("\(product.isComboMeal ? "[COMBO] " : "")\(product.name)")
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
                    .foregroundColor(.red7)
            } else {
                Image(systemName: "heart")
                    .foregroundColor(.red7)
            }
        })
    }
}
