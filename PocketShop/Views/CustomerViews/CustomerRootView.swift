import SwiftUI

struct CustomerRootView: View {
    let tabData = [
        TabItem(title: Text("Home"), image: Image(systemName: "house"), tag: 0),
        TabItem(title: Text("Orders"), image: Image(systemName: "list.bullet"), tag: 1),
        TabItem(title: Text("Cart"), image: Image(systemName: "cart"), tag: 2),
        TabItem(title: Text("Profile"), image: Image(systemName: "person"), tag: 3)
    ]

    @State var currentTab: Int = 1

    @StateObject var viewRouter = CustomerViewRouter()
    @StateObject var customerViewModel = CustomerViewModel()

    @EnvironmentObject var router: MainViewRouter

    var body: some View {
        TabView(selection: $viewRouter.currentPage) {

            CustomerHomeScreen()
                .tabItem {
                    TabItemView(tabItem: tabData[0])
                }.tag(CustomerViewRouter.Page.home)

            CustomerOrderScreen(viewModel: .init(customerViewModel: customerViewModel))
                .tabItem {
                    TabItemView(tabItem: tabData[1])
                }.tag(CustomerViewRouter.Page.search)

            CustomerCartScreen(viewModel: .init(customerViewModel: customerViewModel))
                .tabItem {
                    TabItemView(tabItem: tabData[2])
                }.tag(CustomerViewRouter.Page.cart)

            CustomerProfileScreen(router: router)
                .tabItem {
                    TabItemView(tabItem: tabData[3])
                }.tag(CustomerViewRouter.Page.profile)
        }.environmentObject(customerViewModel)
    }
}

struct CustomerRootView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerRootView()
            .environmentObject(MainViewRouter())
    }
}

struct TabItem: Identifiable {
    var id = UUID()
    var title: Text
    var image: Image
    var tag: Int
}

struct TabItemView: View {

    var tabItem: TabItem

    var body: some View {
        VStack {
            tabItem.title
            tabItem.image
        }
    }
}
