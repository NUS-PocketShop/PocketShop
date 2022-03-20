import SwiftUI

struct ShopProductsView: View {
    @StateObject var viewModel: VendorViewModel
    @State var showModal = false

    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(viewModel.shop.name)
                        .font(.appTitle)
                        .padding(.bottom)

                    Text(viewModel.shop.description)
                        .font(.appBody)
                        .padding(.bottom)
                }

                URLImage(urlString: viewModel.shop.imageURL)
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Might change to relative sizes
            }

            List {
                ForEach(viewModel.shop.soldProducts, id: \.self) { product in
                    if product.shopName == viewModel.shop.name {
                        NavigationLink(destination: ProductView(product: product)) {
                            ProductListView(product: product)
                        }
                    }
                }
                .onDelete { _ in
                    // Delete item from db
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

struct ShopProductsView_Previews: PreviewProvider {
    static var previews: some View {
        ShopProductsView(viewModel: VendorViewModel())
    }
}
