import SwiftUI

struct VendorRootView: View {
    let tabData = [
        TabItem(title: Text("Home"), image: Image(systemName: "house"), tag: 0),
        TabItem(title: Text("Orders"), image: Image(systemName: "tag"), tag: 1),
        TabItem(title: Text("Profile"), image: Image(systemName: "person"), tag: 2)
    ]

    @State var currentTab: Int = 0

    @StateObject var viewRouter = VendorViewRouter()

    @EnvironmentObject var router: MainViewRouter

    var body: some View {
        TabView(selection: $viewRouter.currentPage) {

            Text("home")
                .tabItem {
                    tabData[0].title
                    tabData[0].image
                }.tag(VendorViewRouter.Page.home)

            Text("orders")
                .tabItem {
                    tabData[1].title
                    tabData[1].image
                }.tag(VendorViewRouter.Page.orders)

            VendorProfileScreen(router: router)
                .tabItem {
                    tabData[2].title
                    tabData[2].image
                }.tag(VendorViewRouter.Page.profile)
        }
    }
}

struct VendorRootView_Previews: PreviewProvider {
    static var previews: some View {
        VendorRootView()
            .environmentObject(MainViewRouter())
    }
}
