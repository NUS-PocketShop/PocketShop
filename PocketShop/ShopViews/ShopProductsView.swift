import SwiftUI

struct ShopProductsView: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @State var showModal = false
    var shop: Shop

    var body: some View {
        VStack {
            ShopHeader(name: shop.name,
                       description: shop.description,
                       imageUrl: shop.imageURL)

            Spacer()
            if shop.soldProducts.isEmpty {
                Text("This shop has no products... yet!")
            } else {
                List {
                    ForEach(shop.soldProducts, id: \.self) { product in
                        NavigationLink(destination: ProductView(product: product)) {
                            ProductListView(product: product)
                        }
                    }
                    .onDelete { positions in
                        viewModel.deleteProduct(at: positions)
                    }
                }
            }
            AddProductButton(showModal: $showModal)
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showModal) {
            NavigationView {
                ShopProductFormView(viewModel: viewModel)
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
