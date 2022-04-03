import SwiftUI

struct ShopProductsView: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @State private var showEditProductModal = false
    @State private var showEditShopModal = false
    var shop: Shop

    var body: some View {
        VStack {
            ShopHeader(name: shop.name,
                       description: shop.description,
                       imageUrl: shop.imageURL)

            Spacer()
            Text("Shop is currently \(shop.isClosed ? "CLOSED" : "Open")")
            Spacer()
            if shop.soldProducts.isEmpty {
                Text("This shop has no products... yet!")
            } else {
                List {
                    ForEach(shop.categories, id: \.self) { shopCategory in
                        Section(header: Text(shopCategory.title).font(Font.headline.weight(.black))) {
                            ForEach(shop.soldProducts, id: \.self) { product in
                                if product.shopCategory?.title == shopCategory.title {
                                    NavigationLink(destination: ShopProductEditFormView(viewModel: viewModel,
                                                                                        product: product)) {
                                        ProductListView(product: product)
                                    }
                                }
                            }
                            .onDelete { positions in
                                viewModel.deleteProduct(at: positions)
                            }
                        }
                    }
                }
            }

            AddProductButton(showModal: $showEditProductModal)

            Spacer()
        }
        .padding()
        .toolbar {
            Button(action: {
                showEditShopModal = true
            }, label: {
                Image(systemName: "square.and.pencil")
            })
        }
        .sheet(isPresented: $showEditProductModal) {
            NavigationView {
                ShopProductFormView()
            }
        }
        .sheet(isPresented: $showEditShopModal) {
            NavigationView {
                ShopEditFormView(viewModel: viewModel, shop: shop)
            }
        }
    }
}

struct ShopHeader: View {

    var name: String
    var description: String
    var imageUrl: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.appTitle)
                    .padding(.bottom)

                Text(description)
                    .font(.appBody)
                    .padding(.bottom)
            }
            Spacer()
            URLImage(urlString: imageUrl)
                .scaledToFit()
                .frame(width: 100, height: 100) // Might change to relative sizes
        }.padding()
    }
}

struct AddProductButton: View {
    @Binding var showModal: Bool

    var body: some View {
        PSButton(title: "Add item to menu") {
            showModal = true
        }
        .buttonStyle(FillButtonStyle())
        .padding(.horizontal)
    }
}
