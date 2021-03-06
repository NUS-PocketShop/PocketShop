import Combine
import SwiftUI

final class VendorViewModel: ObservableObject {

    @Published var vendor: Vendor?
    @Published var currentShop: Shop?
    @Published var products: [Product] = [Product]()
    @Published var orders: [Order] = [Order]()
    @Published var locations: [Location] = [Location]()

    var shopName: String {
        currentShop?.name ?? "My Shop"
    }

    init() {
        DatabaseInterface.auth.getCurrentUser { [self] error, user in
            guard resolveErrors(error) else {
                return
            }
            if let vendor = user as? Vendor {
                self.vendor = vendor
                initialiseShop(vendor.id)
                observeLocations()
            }
        }
    }

    // MARK: User intents
    func createShop(shop: Shop, image: UIImage) {
        DatabaseInterface.db.createShop(shop: shop, imageData: image.pngData())
    }

    func editShop(newShop: Shop, image: UIImage) {
        DatabaseInterface.db.editShop(shop: newShop, imageData: image.pngData())
    }

    func toggleShopOpenClose() {
        guard let shopId = currentShop?.id,
              let isShopClosed = currentShop?.isClosed else {
            return
        }
        if isShopClosed {
            DatabaseInterface.db.openShop(id: shopId)
        } else {
            DatabaseInterface.db.closeShop(id: shopId)
        }
    }

    func cancelOrder(orderId: ID) {
        DatabaseInterface.db.cancelOrder(id: orderId)
    }

    func getOrderedCategoryProducts(category: ShopCategory?) -> [Product] {
        guard let currentShop = currentShop, let category = category else {
            return []
        }
        let products = currentShop.soldProducts
        let orderedProducts = products.filter { $0.shopCategory?.title == category.title }
                                      .sorted { $0.categoryOrderingIndex < $1.categoryOrderingIndex }
        return orderedProducts
    }

    func setOrderAccept(orderId: ID) {
        setOrderStatus(orderId: orderId, status: .accepted)
    }

    func setOrderPreparing(orderId: ID) {
        setOrderStatus(orderId: orderId, status: .preparing)
    }

    func setOrderReady(orderId: ID) {
        setOrderStatus(orderId: orderId, status: .ready)
    }

    func setOrderCollected(orderId: ID) {
        setOrderStatus(orderId: orderId, status: .collected)
    }

    func getLocationIdFromName(locationName: String) -> ID {
        locations.first(where: { $0.name == locationName })?.id ?? ID(strVal: "")
    }

    func getLocationNameFromId(locationId: ID) -> String {
        locations.first(where: { $0.id == locationId })?.name ?? ""
    }

    // MARK: Private functions
    private func initialiseShop(_ vendorId: ID) {
        DatabaseInterface.db.observeShopsByOwner(ownerId: vendorId) { [self] error, allShops, eventType in
            guard resolveErrors(error) else {
                return
            }

            if let allShops = allShops, let eventType = eventType, !allShops.isEmpty {
                if eventType == .added || eventType == .updated {
                    currentShop = allShops[0]
                    products = allShops[0].soldProducts
                    getOrders(allShops[0].id)
                } else if eventType == .deleted {
                    currentShop = nil
                    products = [Product]()
                    orders = [Order]()
                }
            }
        }
    }

    private func getOrders(_ shopId: ID) {
        DatabaseInterface.db.observeOrdersFromShop(shopId: shopId) { [self] error, allOrders, eventType in
            guard resolveErrors(error) else {
                return
            }
            if let allOrders = allOrders {
                if eventType == .added || eventType == .updated {
                    for order in allOrders {
                        orders.removeAll(where: { $0.id == order.id })
                        orders.append(order)
                    }
                } else if eventType == .deleted {
                    for order in allOrders {
                        orders.removeAll(where: { $0.id == order.id })
                    }
                }
            }
        }
    }

    private func setOrderStatus(orderId: ID, status: OrderStatus) {
        let filteredOrder = self.orders.filter { order in
            order.id == orderId
        }

        guard filteredOrder.count == 1 else {
            fatalError("The order id \(orderId) does not appear in order")
        }

        let order = filteredOrder[0]

        let editedOrder = Order(id: order.id,
                                orderProducts: order.orderProducts,
                                status: status,
                                customerId: order.customerId,
                                shopId: order.shopId,
                                shopName: order.shopName,
                                date: order.date,
                                collectionNo: order.collectionNo)

        DatabaseInterface.db.editOrder(order: editedOrder)
    }

    private func observeLocations() {
        DatabaseInterface.db.observeAllLocations { [self] error, allLocations, eventType in
            guard resolveErrors(error) else {
                return
            }
            if let allLocations = allLocations, let eventType = eventType {
                if eventType == .added || eventType == .updated {
                    for location in allLocations {
                        locations.removeAll(where: { $0.id == location.id })
                        locations.append(location)
                    }
                } else if eventType == .deleted {
                    for location in allLocations {
                        locations.removeAll(where: { $0.id == location.id })
                    }
                }
            }
        }
    }

    private func resolveErrors(_ error: Error?) -> Bool {
        if let error = error {
            print("there was an error: \(error.localizedDescription)")
            return false
        }
        return true
    }
}
