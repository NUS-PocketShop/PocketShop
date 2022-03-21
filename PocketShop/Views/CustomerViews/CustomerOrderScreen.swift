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
                ForEach(viewModel.filteredOrders) { order in
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
    func OrderItem(order: AdaptedOrder) -> some View {
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
                    Text("\(orderProduct.quantity) x \(orderProduct.name)")
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

                RingView(color: order.ringColor, text: order.statusAsString)

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
    struct AdaptedOrder: Identifiable {
        var id: String
        var collectionNo: Int
        var shopName: String
        var total: Double
        var orderProducts: [AdaptedOrderProduct]
        var status: OrderStatus
        var isHistory: Bool {
            status == .collected
        }
        var statusAsString: String {
            switch status {
            case .pending:
                return "PENDING"
            case .accepted:
                return "ACCEPTED"
            case .preparing:
                return "PREPARING"
            case .ready:
                return "READY"
            case .collected:
                return "COLLECTED"
            }
        }
        var ringColor: Color {
            switch status {
            case .pending, .accepted, .preparing:
                return .gray6
            case .ready, .collected:
                return .success
            }
        }
        var orderDate: Date
        private let dateFormatter = DateFormatter()

        var orderDateString: String {
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return dateFormatter.string(from: orderDate)
        }
        var orderTimeString: String {
            dateFormatter.dateFormat = "HH:mm a"
            return dateFormatter.string(from: orderDate)
        }
        
        static func from(order: Order) -> AdaptedOrder {
            let total = order.orderProducts.reduce(0) { res, orderProduct in
                res + Double(orderProduct.quantity) * orderProduct.product.price
            }
            
            let adaptedOrderProducts = order.orderProducts.map { orderProduct in
                AdaptedOrderProduct.from(orderProduct: orderProduct)
            }
            
            return AdaptedOrder(id: order.id,
                                collectionNo: 123,
                                shopName: order.orderProducts[0].product.shopName,
                                total: total,
                                orderProducts: adaptedOrderProducts,
                                status: order.status,
                                orderDate: order.date)
        }
    }

    struct AdaptedOrderProduct {
        var id: String
        var name: String
        var quantity: Int
        
        static func from(orderProduct: OrderProduct) -> AdaptedOrderProduct {
            AdaptedOrderProduct(id: orderProduct.id,
                                name: orderProduct.product.name,
                                quantity: orderProduct.quantity)
        }
    }

    class ViewModel: ObservableObject {
        private var customerViewModel = CustomerViewModel()
        @Published var orders: [Order] =  []
        @Published var filteredOrders: [AdaptedOrder] = []

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
                
                DatabaseInterface.db.observeOrdersFromCustomer(customerId: user.id) { [self] error, orders in
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
            }.map(AdaptedOrder.from)
        }

        func setFilterHistory() {
            filteredOrders = orders.filter { order in
                order.status != .collected
            }.map(AdaptedOrder.from)
        }
    }
}

struct CustomerOrderScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerOrderScreen(viewModel: .init())
    }
}
