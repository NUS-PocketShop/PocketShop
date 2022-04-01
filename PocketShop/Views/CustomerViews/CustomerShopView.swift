import SwiftUI

struct CustomerShopView: View {
    @StateObject var viewModel: CustomerViewModel
    var shop: Shop

    var body: some View {
        VStack {
            ShopHeader(name: shop.name,
                       description: shop.description,
                       imageUrl: shop.imageURL)
            Spacer()
            if (!viewModel.products.contains(where: { $0.shopName == shop.name })) {
                Text("This shop has no products... yet!")
                Spacer()
            } else {
                List {
                    ForEach(viewModel.products) { product in
                        if product.shopName == shop.name {
                            NavigationLink(destination: ProductView(product: product)) {
                                ProductListView(product: product).environmentObject(viewModel)
                            }
                        }
                    }
                }
            }

        }
    }
}

struct CustomerShopView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CustomerViewModel()
        let sampleShop = viewModel.shops.first(where: { shop in
            shop.name == "Gong Cha"
        })
        CustomerShopView(viewModel: viewModel, shop: sampleShop!)
    }
}
