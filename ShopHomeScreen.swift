import SwiftUI

struct ShopHomeScreen: View {

    @EnvironmentObject var viewModel: VendorViewModel

    var body: some View {
        NavigationView {
            VStack {
                if let shop = viewModel.currentShop {
                    ShopInfoView(shop: shop)
                } else {
                    AddShopDetailsView()
                }
            }
            .navigationTitle(viewModel.shopName)
            .font(.appHeadline)
            .toolbar {
                if let shop = viewModel.currentShop {
                    Button {
                        // edit the current shop's items
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(viewModel)
    }
}

struct ShopHomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShopHomeScreen()
    }
}

struct AddShopDetailsView: View {
    @State private var isAddingShop = false

    var body: some View {
        Text("Your shop is not created yet! Press the '+' button to get started.")
            .font(.appBody)
        NavigationLink(
            destination: EditShopDetailsScreen(),
            isActive: $isAddingShop) {
            PSButton(title: "+") {
                isAddingShop = true
            }.buttonStyle(OutlineButtonStyle())
        }
    }
}
