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
                    tabData[0].title
                    tabData[0].image
                }.tag(CustomerViewRouter.Page.home)

            CustomerOrderScreen(viewModel: .init(customerViewModel: customerViewModel))
                .tabItem {
                    tabData[1].title
                    tabData[1].image
                }.tag(CustomerViewRouter.Page.search)

            CustomerCartScreen()
                .tabItem {
                    tabData[2].title
                    tabData[2].image
                }.tag(CustomerViewRouter.Page.cart)

            CustomerProfileScreen(router: router)
                .tabItem {
                    tabData[3].title
                    tabData[3].image
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
