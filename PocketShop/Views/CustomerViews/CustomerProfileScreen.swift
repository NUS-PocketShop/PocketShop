import SwiftUI

struct CustomerProfileScreen: View {

    @EnvironmentObject var viewModel: CustomerViewModel
    @State var router: MainViewRouter
    @State var willNavigateOrder = false
    @State var isViewingFavourites = false
    @State var isViewingCoupons = false

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: CustomerFavouritesScreen(),
                               isActive: $isViewingFavourites) {
                    PSButton(title: "View Favourited Products") {
                        isViewingFavourites = true
                    }
                }

                NavigationLink(destination: CouponRedemptionScreen(),
                               isActive: $isViewingCoupons) {
                    PSButton(title: "Redeem Coupons") {
                        isViewingCoupons = true
                    }
                }

                Spacer()

                PSButton(title: "Logout",
                         icon: "arrow.down.left.circle.fill") {
                    signOut()
                }
                .buttonStyle(FillButtonStyle())

            }
            .padding()
            .buttonStyle(SecondaryButtonStyle())
            .navigationTitle("Profile/Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    private func signOut() {
        DatabaseInterface.auth.signOutUser()
        router.currentPage = .login
    }
}

struct CustomerProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerProfileScreen(router: MainViewRouter())
    }
}
