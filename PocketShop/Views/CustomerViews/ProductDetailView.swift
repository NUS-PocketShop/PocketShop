import SwiftUI

struct ProductDetailView: View {
    var product: Product

    var body: some View {
        VStack {
            Text(product.name)
                .font(.appTitle)

            URLImage(urlString: product.imageURL)
                .scaledToFit()
                .frame(width: 150, height: 150) // Might change to relative sizes

            Text(product.description)
                .padding(.vertical)
                .font(.appBody)

            Text(String(format: "$%.2f", product.price))
                .font(.appBody)
                .fontWeight(.semibold)

            ProductOrderBar(product: product)
        }
        .toolbar {
            FavouritesButton(itemId: product.id)
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProduct = CustomerViewModel().products.first!
        ProductDetailView(product: sampleProduct).environmentObject(CustomerViewModel())
    }
}

struct FavouritesButton: View {
    @EnvironmentObject var viewModel: CustomerViewModel

    var itemId: String

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
