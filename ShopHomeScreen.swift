import SwiftUI

struct ShopHomeScreen: View {

    @EnvironmentObject var viewModel: VendorViewModel

    var body: some View {
        NavigationView {
            if let shop = viewModel.currentShop {
                ShopProductsView(shop: shop)
            } else {
                AddShopDetailsView()
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
        VStack(spacing: 12) {
            Text("Your shop is not created yet! Tap the '+' button to get started")
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
}
