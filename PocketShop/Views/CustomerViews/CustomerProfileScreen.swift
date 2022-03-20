import SwiftUI

struct CustomerProfileScreen: View {

    @State var router: MainViewRouter
    @State var willNavigateOrder = false

    var body: some View {
        NavigationView {
            VStack {
                PSButton(title: "Change Password") {}
                Spacer()
                PSButton(title: "Logout",
                         icon: "arrow.down.left.circle.fill") {
                    signOut()
                }
                .buttonStyle(FillButtonStyle())
            }
            .padding()
            .buttonStyle(SecondaryButtonStyle())
        }
        .navigationViewStyle(.stack)
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
