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
        VStack {
            Picker("Selected View", selection: $viewModel.tabSelection) {
                Text("Current").tag(TabView.current)
                Text("History").tag(TabView.history)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            
            OrderList()
        }
        .navigationTitle("My Orders")
    }
    
    @ViewBuilder
    func OrderList() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(viewModel.filteredOrders) { order in
                    OrderItem(order: order)
                }
                .frame(maxWidth: .infinity, minHeight: 96)
                .padding(.horizontal, 12)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func OrderItem(order: AdaptedOrder) -> some View {
        HStack(alignment: .top){
            VStack {
                Text("COLLECTION NO.")
                    .font(.appBody)
                
                Text("\(order.collectionNo)")
                    .font(.appFont(size: 32))
                    .bold()
            }
            
            VStack {
                Text("\(order.shopName)")
                    .font(.appBody)
                    .bold()
                
                ForEach(order.orderProducts, id: \.id) { orderProduct in
                    Text("\(orderProduct.quantity) x \(orderProduct.name)")
                        .font(.appSmallCaption)
                }
            }
            
            Spacer()
            
            VStack {
                Text(String(format: "$%2.f", order.total))
                    .font(.appBody)
                    .bold()
                    .padding(.bottom, 12)
                
                Text("\(order.statusAsString)")
                    .font(.appBody)
            }
            .frame(width: 84)
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
                return "Pending"
            case .accepted:
                return "Accepted"
            case .preparing:
                return "Preparing"
            case .ready:
                return "Ready"
            case .collected:
                return "Collected"
            }
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
                status: .preparing),
            AdaptedOrder(
                id: "3", collectionNo: 225, shopName: "Cool Spot", total: 13.60,
                orderProducts: [AdaptedOrderProduct(id: "9", name: "Coffee", quantity: 3),
                                AdaptedOrderProduct(id: "10", name: "Chocolate Bun", quantity: 2)],
                status: .ready)
        ]
        
        var pastOrders: [AdaptedOrder] = [
            AdaptedOrder(
                id: "2", collectionNo: 999, shopName: "Cool Spot", total: 13.60,
                orderProducts: [AdaptedOrderProduct(id: "1", name: "Green Bean Bun", quantity: 10),
                                AdaptedOrderProduct(id: "2", name: "Red Bean Bun", quantity: 2)],
                status: .preparing)
        ]
        
        @Published var filteredOrders: [AdaptedOrder] = [
            AdaptedOrder(
                id: "1", collectionNo: 220, shopName: "Cool Spot", total: 13.60,
                orderProducts: [AdaptedOrderProduct(id: "1", name: "Red Bean Bun", quantity: 10)],
                status: .preparing),
            AdaptedOrder(
                id: "3", collectionNo: 225, shopName: "Cool Spot", total: 13.60,
                orderProducts: [AdaptedOrderProduct(id: "9", name: "Coffee", quantity: 3),
                                AdaptedOrderProduct(id: "10", name: "Chocolate Bun", quantity: 2)],
                status: .ready)
        ]
        
        @Published var tabSelection: TabView = .current {
            didSet {
                // Idea: any time the tab is switched, we should fetch the relevant order
                //       Not sure whether we need async here
                switch tabSelection {
                case .current:
                    filteredOrders = currentOrders
                case .history:
                    filteredOrders = pastOrders
                }
            }
        }
        
        func fetchCurrentOrders() {
            
        }
        
        func fetchPastOrders() {
            
        }
    }
}

struct CustomerOrderScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CustomerOrderScreen(viewModel: CustomerOrderScreen.ViewModel())
        }
    }
}
