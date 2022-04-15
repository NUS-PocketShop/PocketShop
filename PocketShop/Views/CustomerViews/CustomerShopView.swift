import SwiftUI

struct CustomerShopView: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var shop: Shop

    var body: some View {
        VStack {
            ShopHeader(name: shop.name,
                       location: viewModel.getLocationNameFromLocationId(locationId: shop.locationId),
                       description: shop.description,
                       imageUrl: shop.imageURL)
            Spacer()
            ShopStatus(shop: shop)
            Spacer()
            ShopProductsList(shop: shop)
        }
    }
}

struct ShopStatus: View {
    var shop: Shop
    var body: some View {
        if shop.isClosed {
            Text("This shop is currently closed. You may not be able to place orders.")
        }
    }
}

struct ShopProductsList: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var shop: Shop

    var body: some View {
        if (!viewModel.products.contains(where: { $0.shopName == shop.name })) {
            Text("This shop has no products... yet!")
            Spacer()
        } else {
            Text("Menu")
                .font(.appTitle)
            List {
                ForEach(shop.categories, id: \.self) { shopCategory in
                    Section(header: Text(shopCategory.title).font(Font.headline.weight(.black))) {
                        ForEach(shop.soldProducts, id: \.self) { product in
                            if product.shopCategory?.title == shopCategory.title {
                                ProductPreview(product: product,
                                               isClosed: shop.isClosed)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ProductPreview: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    @State var product: Product
    var isClosed = false

    var body: some View {
        VStack {
            if isClosed || product.isOutOfStock {
                ProductListView(product: product).environmentObject(viewModel)
                    .opacity(isClosed ? 0.5 : 1)
            } else {
                NavigationLink(destination: ProductDetailView(product: product)) {
                    ProductListView(product: product).environmentObject(viewModel)
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
        CustomerShopView(shop: sampleShop!).environmentObject(viewModel)
    }
}
