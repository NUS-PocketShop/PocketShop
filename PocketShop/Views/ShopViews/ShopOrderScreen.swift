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
                    Text("Incoming").tag(TabView.current)
                    Text("Preparing").tag(TabView.preparing)
                    Text("Ready").tag(TabView.ready)
                    Text("History").tag(TabView.history)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                withAnimation(.easeInOut) {
                    OrderList()
                }
            }
            .navigationTitle("All Orders")
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
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func OrderItem(order: OrderViewModel) -> some View {
        HStack(alignment: .top) {
            CollectionNumberSection(order: order)
            OrderDetailsSection(order: order)
            Spacer()
            OrderStatusSection(order: order)
        }
    }

    @ViewBuilder
    func OrderStatusSection(order: OrderViewModel) -> some View {
        VStack {
            Text(String(format: "$%.2f", order.total))
                .font(.appBody)
                .bold()
                .padding(.bottom, 12)

            Spacer()

            StatusRing(order: order)

            Spacer()

            if !order.isHistory {
                ToggleOrderStatusButton(order: order)
            }

            if order.showCancel {
                PSButton(title: "Cancel") {
                    showCancelConfirmation.toggle()
                    selectedOrder = order
                }
                .frame(height: 64)
                .buttonStyle(FillButtonStyle())
                .alert(isPresented: $showCancelConfirmation) {
                    guard let selectedOrder = self.selectedOrder else {
                        fatalError("Order does not exist")
                    }

                    return getCancelAlertForOrder(selectedOrder)
                }
            }
        }
        .frame(width: 100)
        .frame(minHeight: 128)
    }

    @ViewBuilder
    func ToggleOrderStatusButton(order: OrderViewModel) -> some View {
        PSButton(title: order.buttonText) {
            showConfirmation.toggle()
            selectedOrder = order
        }
        .frame(height: 64)
        .buttonStyle(FillButtonStyle())
        .alert(isPresented: $showConfirmation) {
            guard let selectedOrder = self.selectedOrder else {
                fatalError("Order does not exist")
            }

            return getAlertForOrder(selectedOrder)
        }
    }

    @ViewBuilder
    func StatusRing(order: OrderViewModel) -> some View {
        RingView(color: order.ringColor, text: order.status.toString())
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
        case current
        case preparing
        case ready
        case history
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
            case .preparing:
                setFilterPreparing()
            case .ready:
                setFilterReady()
            case .history:
                setFilterHistory()
            }
        }

        func setFilterCurrent() {
            filteredOrders = vendorViewModel.orders.filter { order in
                order.status == .pending
            }.sorted {
                $0.date < $1.date
            }.map {
                OrderViewModel(order: $0)
            }
        }

        func setFilterPreparing() {
            filteredOrders = vendorViewModel.orders.filter { order in
                order.status == .preparing || order.status == .accepted
            }.sorted {
                $0.date > $1.date
            }.map {
                OrderViewModel(order: $0)
            }
        }

        func setFilterReady() {
            filteredOrders = vendorViewModel.orders.filter { order in
                order.status == .ready
            }.sorted {
                $0.date > $1.date
            }.map {
                OrderViewModel(order: $0)
            }
        }

        func setFilterHistory() {
            filteredOrders = vendorViewModel.orders.filter { order in
                order.status == .collected || order.status == .cancelled
            }.sorted {
                $0.date > $1.date
            }.map {
                OrderViewModel(order: $0)
            }
        }

        func cancelOrder(order: OrderViewModel) {
            vendorViewModel.cancelOrder(orderId: order.id)
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
