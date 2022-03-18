import SwiftUI

struct VendorProfileScreen: View {

    @State var router: MainViewRouter

    var body: some View {
        NavigationView {
            VStack {
                PSButton(title: "Edit Shop") {}
                PSButton(title: "Change Password") {}
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

struct VendorProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        VendorProfileScreen(router: MainViewRouter())
    }
}
