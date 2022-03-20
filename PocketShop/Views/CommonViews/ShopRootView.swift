import SwiftUI

struct ShopRootView: View {
    let tabData = [
        TabItem(title: Text("Home"), image: Image(systemName: "house"), tag: 0),
        TabItem(title: Text("Orders"), image: Image(systemName: "list.bullet"), tag: 1),
        TabItem(title: Text("Profile"), image: Image(systemName: "person"), tag: 2)
    ]

    @State var currentTab: Int = 0

    @StateObject var viewRouter = ShopViewRouter()
    @StateObject var viewModel = VendorViewModel()

    @EnvironmentObject var router: MainViewRouter

    var body: some View {
        TabView(selection: $viewRouter.currentPage) {

            ShopHomeScreen()
                .tabItem {
                    tabData[0].title
                    tabData[0].image
                }.tag(ShopViewRouter.Page.home)

            ShopOrderScreen(viewModel: .init())
                .tabItem {
                    tabData[1].title
                    tabData[1].image
                }.tag(ShopViewRouter.Page.orders)

            ShopProfileScreen(router: router)
                .tabItem {
                    tabData[2].title
                    tabData[2].image
                }.tag(ShopViewRouter.Page.profile)
        }
        .environmentObject(viewModel)
    }
}

struct ShopRootView_Previews: PreviewProvider {
    static var previews: some View {
        ShopRootView()
            .environmentObject(MainViewRouter())
    }
}
