import SwiftUI

struct ShopOrderScreen: View {
    @ObservedObject private(set) var viewModel: ViewModel
    @State private var showConfirmation = false
    @State private var selectedOrder: Order?

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
                    .onTapGesture {
                        showConfirmation.toggle()
                        selectedOrder = order
                    }
                    .alert(isPresented: $showConfirmation) {
                        guard let selectedOrder = self.selectedOrder else {
                            // TODO: show user-friendly error message
                            fatalError("Order does not exist")
                        }
                        
                        return getAlertForOrder(selectedOrder)
                    }

                Spacer()
            }
            .frame(minHeight: 128)
        }
    }
    
    private func getAlertForOrder(_ order: Order) -> Alert {
        if order.status == .accepted {
            return Alert(
                title: Text("Confirmation"),
                message: Text("Confirm that order \(order.collectionNo) is ready?"),
                primaryButton: .default(Text("Confirm")) {
                    viewModel.setOrderReady(order: order)
                },
                secondaryButton: .destructive(Text("Cancel")))
        }
        
        assert(order.status == .ready, "Implement order collection type of \(order.status)!")
        
        return Alert(
            title: Text("Confirmation"),
            message: Text("Confirm that order \(order.collectionNo) is collected?"),
            primaryButton: .default(Text("Confirm")) {
                viewModel.setOrderCollected(order: order)
            },
            secondaryButton: .destructive(Text("Cancel")))
    }
}

extension ShopOrderScreen {
    enum TabView: String {
        case current = "current"
        case history = "history"
    }
}

// MARK: view model
extension ShopOrderScreen {
    class ViewModel: ObservableObject {
        @ObservedObject private var vendorViewModel: VendorViewModel
        @Published var orders: [Order] =  []
        @Published var filteredOrders: [Order] = []

        @Published var tabSelection: TabView {
            didSet {
                updateFilter()
            }
        }

        init(vendorViewModel: VendorViewModel) {
            self.vendorViewModel = vendorViewModel
            tabSelection = .current
            fetchOrder(shop: vendorViewModel.currentShop)
        }
        
        private func fetchOrder(shop: Shop?) {
            guard let shop = shop else {
                return
            }
            
            DatabaseInterface.db.observeOrdersFromShop(shopId: shop.id) { [self] error, orders in
                guard let orders = orders else {
                    fatalError("Something wrong when listening to orders")
                }
                self.orders = orders
                self.updateFilter()
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
        
        func setOrderReady(order: Order) {
            var order = order
            order.status = .ready
            
            DatabaseInterface.db.editOrder(order: order)
        }
        
        func setOrderCollected(order: Order) {
            var order = order
            order.status = .collected
            
            DatabaseInterface.db.editOrder(order: order)
        }
    }
}

struct ShopOrderScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShopOrderScreen(viewModel: .init(vendorViewModel: VendorViewModel()))
    }
}

