import SwiftUI

struct CustomerSearchScreen: View {
    var body: some View {
        NavigationView {
            Text("Search Screen")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomerSearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerSearchScreen()
    }
}
