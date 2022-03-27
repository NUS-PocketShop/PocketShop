import SwiftUI

struct CustomerOrderScreen: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        NavigationView {
            VStack {
                Picker("Selected View", selection: $viewModel.tabSelection) {
                    Text("Current").tag(TabView.current)
                    Text("History").tag(TabView.history)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                withAnimation(.easeInOut) {
                    OrderList()
                }
            }
            .navigationTitle("My Orders")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    func OrderList() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(viewModel.filteredOrders, id: \.id) { order in
                    OrderItem(order: order)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func OrderItem(order: Order) -> some View {
        HStack(alignment: .top) {
            VStack {
                Text("COLLECTION NO.")
                    .font(.appBody)

                Spacer()

                Text("\(order.collectionNo)")
                    .font(.appFont(size: 32))
                    .bold()

                Spacer()

                Text("\(order.orderDateString)")
                    .font(.appBody)

                Text("\(order.orderTimeString)")
                    .font(.appBody)
                    .foregroundColor(.gray)
            }
            .frame(minWidth: 100)

            VStack(alignment: .leading, spacing: 0) {
                Text("\(order.shopName)")
                    .font(.appBody)
                    .bold()
                    .padding(.bottom, 4)

                ForEach(order.orderProducts, id: \.id) { orderProduct in
                    Text("\(orderProduct.quantity) x \(orderProduct.product.name)")
                        .font(.appSmallCaption)
                }

                Spacer()
            }
            .padding(.leading, 8)

            Spacer()

            VStack {
                Text(String(format: "$%2.f", order.total))
                    .font(.appBody)
                    .bold()
                    .padding(.bottom, 12)

                Spacer()

                RingView(color: order.ringColor, text: order.status.toString())

                Spacer()
            }
            .frame(minHeight: 128)
        }
    }
}

extension CustomerOrderScreen {
    enum TabView: String {
        case current = "current"
        case history = "history"
    }
}

// MARK: view model
extension CustomerOrderScreen {
    class ViewModel: ObservableObject {
        @Published var orders: [Order] = []
        @Published var filteredOrders: [Order] = []

        @Published var tabSelection: TabView {
            didSet {
                updateFilter()
            }
        }

        init() {
            tabSelection = .current
            fetchOrder()
        }

        private func fetchOrder() {
            DatabaseInterface.auth.getCurrentUser { _, user in
                guard let user = user else {
                    print("No user")
                    return
                }

                DatabaseInterface.db.observeOrdersFromCustomer(customerId: user.id) { [self] _, orders in
                    guard let orders = orders else {
                        fatalError("Something wrong when listening to orders")
                    }
                    self.orders = orders
                    self.updateFilter()
                }
            }
        }

        private func updateFilter() {
            switch tabSelection {
            case .current:
                setFilterCurrent()
            case .history:
                setFilterHistory()
            }
        }

        func setFilterCurrent() {
            filteredOrders = orders.filter { order in
                order.status != .collected
            }
        }

        func setFilterHistory() {
            filteredOrders = orders.filter { order in
                order.status == .collected
            }
        }
    }
}

struct CustomerOrderScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerOrderScreen(viewModel: .init())
    }
}
