import SwiftUI

struct CustomerProfileScreen: View {

    @State var router: MainViewRouter

    var body: some View {
        NavigationView {
            VStack {
                PSButton(title: "View current orders") {}
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

struct CustomerProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerProfileScreen(router: MainViewRouter())
    }
}
