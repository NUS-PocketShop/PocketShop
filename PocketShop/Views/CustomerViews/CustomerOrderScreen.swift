//
//  CustomerOrderScreen.swift
//  PocketShop
//
//  Created by Dasco Gabriel on 16/3/22.
//

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
            dateFormatter.dateFormat = "dd/mm/yyyy"
            return dateFormatter.string(from: orderDate)
        }
        var orderTimeString: String {
            dateFormatter.dateFormat = "HH:mm a"
            return dateFormatter.string(from: orderDate)
        }
    }

    struct AdaptedOrderProduct {
        var id: String
        var name: String
        var quantity: Int
    }

    class ViewModel: ObservableObject {
        var currentOrders: [AdaptedOrder] = [
            AdaptedOrder(
                id: "1", collectionNo: 220, shopName: "Cool Spot", total: 13.60,
                orderProducts: [AdaptedOrderProduct(id: "1", name: "Red Bean Bun", quantity: 10)],
                status: .preparing,
                orderDate: Date()),
            AdaptedOrder(
                id: "3", collectionNo: 225, shopName: "Cool Spot", total: 13.60,
                orderProducts: [AdaptedOrderProduct(id: "9", name: "Coffee", quantity: 3),
                                AdaptedOrderProduct(id: "10", name: "Chocolate Bun", quantity: 2),
                                AdaptedOrderProduct(id: "11", name: "Some order with very long name", quantity: 2),
                                AdaptedOrderProduct(id: "12", name: "Chocolate Bun", quantity: 2),
                                AdaptedOrderProduct(id: "13", name: "Chocolate Bun", quantity: 2),
                                AdaptedOrderProduct(id: "14", name: "Chocolate Bun", quantity: 2),
                                AdaptedOrderProduct(id: "15", name: "Chocolate Bun", quantity: 2),
                                AdaptedOrderProduct(id: "16", name: "Chocolate Bun", quantity: 2)],
                status: .ready,
                orderDate: Date())
        ]

        var pastOrders: [AdaptedOrder] = [
            AdaptedOrder(
                id: "2", collectionNo: 999, shopName: "Cool Spot", total: 13.60,
                orderProducts: [AdaptedOrderProduct(id: "1", name: "Green Bean Bun", quantity: 10),
                                AdaptedOrderProduct(id: "2", name: "Red Bean Bun", quantity: 2)],
                status: .preparing,
                orderDate: Date())
        ]

        @Published var filteredOrders: [AdaptedOrder] = []

        @Published var tabSelection: TabView {
            didSet {
                switch tabSelection {
                case .current:
                    fetchCurrentOrders()
                case .history:
                    fetchOrderHistory()
                }
            }
        }

        init() {
            tabSelection = .current
            fetchCurrentOrders()
        }

        func fetchCurrentOrders() {
            filteredOrders = currentOrders

            // Fetch `currentOrders` from backend and listen for changes
        }

        func fetchOrderHistory() {
            filteredOrders = pastOrders

            // Fetch `pastOrders` from backend and listen for changes
        }
    }
}

struct CustomerOrderScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerOrderScreen(viewModel: .init())
    }
}
