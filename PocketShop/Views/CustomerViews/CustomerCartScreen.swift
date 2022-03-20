import SwiftUI

struct CustomerCartScreen: View {
    var body: some View {
        NavigationView {
            Text("Cart Screen")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomerCartScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerCartScreen()
    }
}
