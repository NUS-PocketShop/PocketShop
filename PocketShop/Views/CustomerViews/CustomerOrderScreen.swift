import SwiftUI

struct CustomerOrderScreen: View {
    @ObservedObject var viewModel: ViewModel
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
        @ObservedObject var customerViewModel: CustomerViewModel
        @Published var filteredOrders: [OrderViewModel] = []

        @Published var tabSelection: TabView {
            didSet {
                updateFilter()
            }
        }

        init(customerViewModel: CustomerViewModel) {
            self.customerViewModel = customerViewModel

            // When we first set the value,
            // it won't call the didSet
            // hence we have to call updateFilter() manually once
            tabSelection = .current
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
            filteredOrders = customerViewModel.orders.filter {
                $0.status != OrderStatus.collected
            }.map {
                OrderViewModel(order: $0)
            }
        }

        func setFilterHistory() {
            filteredOrders = customerViewModel.orders.filter {
                $0.status == OrderStatus.collected
            }.map {
                OrderViewModel(order: $0)
            }
        }

        func cancelOrder(order: OrderViewModel) {
            customerViewModel.deleteOrder(orderId: order.id)
        }
    }
}

struct CustomerOrderScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerOrderScreen(viewModel: .init(customerViewModel: CustomerViewModel()))
            .environmentObject(CustomerViewModel())
    }
}
