import SwiftUI

struct ShopProfileScreen: View {

    @State var router: MainViewRouter
    @EnvironmentObject var viewModel: VendorViewModel

    var body: some View {
        NavigationView {
            VStack {
                ShopOpenCloseButton()
                Spacer()
                PSButton(title: "Logout",
                         icon: "arrow.down.left.circle.fill") {
                    router.currentPage = .login
                }
                .buttonStyle(FillButtonStyle())
            }
            .padding()
            .buttonStyle(SecondaryButtonStyle())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ShopProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShopProfileScreen(router: MainViewRouter())
    }
}

struct ShopOpenCloseButton: View {
    @EnvironmentObject var viewModel: VendorViewModel

    @State private var isShowingAlert = false

    private var status: String {
        guard let shop = viewModel.currentShop else {
            return "unknown"
        }
        return shop.isClosed ? "closed" : "open"
    }

    private var action: String {
        guard let shop = viewModel.currentShop else {
            return "unknown"
        }
        return shop.isClosed ? "open" : "close"
    }

    var body: some View {
        PSButton(title: "Open/Close Shop") {
            isShowingAlert.toggle()
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Open/Close Shop"),
                  message: Text("Your shop is currently \(status), want to \(action) it?"),
                  primaryButton: .default(Text("OK")) {
                    viewModel.toggleShopOpenClose()
                  },
                  secondaryButton: .cancel())
        }
    }
}
