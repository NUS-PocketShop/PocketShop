import SwiftUI

struct CustomerShopView: View {
    @StateObject var viewModel: CustomerViewModel
    var shop: Shop

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

            List {
                ForEach(viewModel.products, id: \.self) { product in
                    if product.shopName == shop.name {
                        NavigationLink(destination: ProductView(product: product).environmentObject(viewModel)) {
                            ProductListView(product: product)
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
