import SwiftUI

struct ShopProfileScreen: View {

    @State var router: MainViewRouter
    @EnvironmentObject var viewModel: VendorViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("vendor id: \(viewModel.vendor?.id ?? "")")
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
