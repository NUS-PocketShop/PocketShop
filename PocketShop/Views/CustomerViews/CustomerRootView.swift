import SwiftUI

struct CustomerRootView: View {
    let tabData = [
        TabItem(title: Text("Home"), image: Image(systemName: "house"), tag: 0),
        TabItem(title: Text("Cart"), image: Image(systemName: "cart"), tag: 1),
        TabItem(title: Text("Orders"), image: Image(systemName: "list.bullet"), tag: 2),
        TabItem(title: Text("Profile"), image: Image(systemName: "person"), tag: 3)
    ]

    @State var currentTab: Int = 1

    @StateObject var viewRouter = CustomerViewRouter()
    @StateObject var customerViewModel = CustomerViewModel()
    var itemsInCart: Int {
        customerViewModel.cart.count
    }
    @EnvironmentObject var router: MainViewRouter

    var body: some View {

        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                TabView(selection: $viewRouter.currentPage) {
                    CustomerHomeScreen()
                        .tabItem { TabItemView(tabItem: tabData[0]) }
                        .tag(CustomerViewRouter.Page.home)

                    CustomerCartScreen(viewModel: .init(customerViewModel: customerViewModel))
                        .tabItem { TabItemView(tabItem: tabData[1]) }
                        .tag(CustomerViewRouter.Page.cart)

                    CustomerOrderScreen(viewModel: .init(customerViewModel: customerViewModel))
                        .tabItem { TabItemView(tabItem: tabData[2]) }.tag(CustomerViewRouter.Page.search)

                    CustomerProfileScreen(router: router)
                        .tabItem { TabItemView(tabItem: tabData[3]) }.tag(CustomerViewRouter.Page.profile)
                }

                PSBadge(badgeNumber: itemsInCart)
                    .offset(x: calculateXOffsetCartBadge(geometry.size.width),
                            y: -25)
                    .opacity(customerViewModel.cart.isEmpty ? 0.0 : 1.0)
            }
            .ignoresSafeArea(.keyboard)

        }.environmentObject(customerViewModel)

    }

    private func calculateXOffsetCartBadge(_ width: CGFloat) -> CGFloat {
        let badgeIndex: CGFloat = 2
        let numTabs: CGFloat = 4
        let result = ((2 * badgeIndex) - 0.95) * (width / (2 * numTabs)) + 2

        return result
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
