import SwiftUI

struct ShopProductsView: View {
    @StateObject var viewModel: VendorViewModel
    @State var showModal = false
    var shop: Shop {
        guard let shop = viewModel.currentShop else {
            return Shop(id: "", name: "", description: "", imageURL: "", isClosed: true, ownerId: "", soldProducts: [])
        }
        return shop
    }

//    init?(viewModel: VendorViewModel) {
//        self._viewModel = StateObject(wrappedValue: viewModel)
//        guard let shop = viewModel.currentShop else {
//            return nil
//        }
//        self.shop = shop
//    }

    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(shop.name)
                        .font(.appTitle)
                        .padding(.bottom)

                    Text(shop.description)
                        .font(.appBody)
                        .padding(.bottom)
                }

                URLImage(urlString: shop.imageURL)
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Might change to relative sizes
            }

            if (!viewModel.products.contains(where: { $0.shopName == shop.name })) {
                Text("This shop has no products... yet!")
            } else {
                List {
                    ForEach(shop.soldProducts, id: \.self) { product in
                        if product.shopName == shop.name {
                            NavigationLink(destination: ProductView(product: product)) {
                                ProductListView(product: product)
                            }
                        }
                    }
                    .onDelete { _ in
                        // Delete item from db
                    }
                }
            }

            // Add item button
            PSButton(title: "+") {
                showModal = true
            }
            .buttonStyle(FillButtonStyle())
            .padding(.horizontal)
        }
        .overlay(ShopProductFormView(viewModel: viewModel, showModal: $showModal))
    }
}
