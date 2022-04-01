import SwiftUI
import Combine

struct ShopOrderScreen: View {
    @ObservedObject private(set) var viewModel: ViewModel
    @State private var showConfirmation = false
    @State private var showCancelConfirmation = false
    @State private var selectedOrder: OrderViewModel?

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
                ForEach(viewModel.filteredOrders, id: \.self) { order in
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
    func OrderItem(order: OrderViewModel) -> some View {
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
                    Text("\(orderProduct.quantity) x \(orderProduct.productName)")
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

                if order.showCancel {
                    PSButton(title: "Cancel") {
                        showCancelConfirmation.toggle()
                        selectedOrder = order
                    }
                    .alert(isPresented: $showCancelConfirmation) {
                        guard let selectedOrder = self.selectedOrder else {
                            fatalError("Order does not exist")
                        }

                        return getCancelAlertForOrder(selectedOrder)
                    }
                    .buttonStyle(FillButtonStyle())
                }
            }
            .frame(minHeight: 128)
        }
    }

    private func getCancelAlertForOrder(_ order: OrderViewModel) -> Alert {
        Alert(title: Text("Confirmation"),
              message: Text("Confirm to cancel order \(order.collectionNo)?"),
              primaryButton: .default(Text("Yes")) {
                    viewModel.cancelOrder(order: order)
              },
              secondaryButton: .destructive(Text("No")))
    }

    private func getAlertForOrder(_ order: OrderViewModel) -> Alert {
        if order.status == .pending {
            return Alert(
                title: Text("Confirmation"),
                message: Text("Confirm to accept order \(order.collectionNo)?"),
                primaryButton: .default(Text("Confirm")) {
                    viewModel.setOrderAccept(order: order)
                },
                secondaryButton: .destructive(Text("Cancel")))
        }

        if order.status == .accepted {
            return Alert(
                title: Text("Confirmation"),
                message: Text("Confirm that order \(order.collectionNo) is ready?"),
                primaryButton: .default(Text("Confirm")) {
                    viewModel.setOrderReady(order: order)
                },
                secondaryButton: .destructive(Text("Cancel")))
        }

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
        @Published var filteredOrders: [OrderViewModel] = []

        @Published var tabSelection: TabView {
            didSet {
                updateFilter()
            }
        }

        init(vendorViewModel: VendorViewModel) {
            self.vendorViewModel = vendorViewModel
            self.tabSelection = .current
            updateFilter()
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
            filteredOrders = vendorViewModel.orders.filter { order in
                order.status != .collected
            }.map {
                OrderViewModel(order: $0)
            }
        }

        func setFilterHistory() {
            filteredOrders = vendorViewModel.orders.filter { order in
                order.status == .collected
            }.map {
                OrderViewModel(order: $0)
            }
        }

        func cancelOrder(order: OrderViewModel) {
            vendorViewModel.deleteOrder(orderId: order.id)
        }

        func setOrderAccept(order: OrderViewModel) {
            vendorViewModel.setOrderAccept(orderId: order.id)
        }

        func setOrderReady(order: OrderViewModel) {
            // Used id so when order needs to be adapted as view model,
            // we can still use this function
            vendorViewModel.setOrderReady(orderId: order.id)
        }

        func setOrderCollected(order: OrderViewModel) {
            vendorViewModel.setOrderCollected(orderId: order.id)
        }
    }
}

struct ShopOrderScreen_Previews: PreviewProvider {
    static var previews: some View {
        ShopOrderScreen(viewModel: .init(vendorViewModel: VendorViewModel()))
    }
}
