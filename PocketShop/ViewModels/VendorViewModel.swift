import Combine
import SwiftUI

final class VendorViewModel: ObservableObject {

    @Published var vendor: Vendor?
    @Published var currentShop: Shop?
    @Published var products: [Product] = [Product]()
    @Published var orders: [Order] = [Order]()

    var shopName: String {
        currentShop?.name ?? "My Shop"
    }

    init() {
        print("initializing vendor view model")
        DatabaseInterface.auth.getCurrentUser { [self] error, user in
            guard resolveErrors(error) else {
                return
            }
            if let vendor = user as? Vendor {
                self.vendor = vendor
                initialiseShop(vendor.id)
            }
        }
    }

    // MARK: User intents
    func createShop(name: String,
                    description: String,
                    image: UIImage) {
        guard let vendor = vendor else {
            // unable to create shop when vendor not initialized
            return
        }

        let shopToCreate = Shop(id: "",
                                name: name,
                                description: description,
                                imageURL: "",
                                isClosed: false,
                                ownerId: vendor.id,
                                soldProducts: [])

        DatabaseInterface.db.createShop(shop: shopToCreate, imageData: image.pngData())
    }

    func createProduct(name: String, description: String, price: Double, estimatedPrepTime: Double, image: UIImage) {
        guard let shop = currentShop else {
            print("No current shop!")
            return
        }

        let product = Product(id: "",
                              name: name,
                              shopName: shop.name,
                              shopId: shop.id,
                              description: description,
                              price: price,
                              imageURL: "",
                              estimatedPrepTime: estimatedPrepTime,
                              isOutOfStock: false,
                              options: [])

        DatabaseInterface.db.createProduct(shopId: shop.id, product: product, imageData: image.pngData())
    }

    func editProduct(oldProductId: String, name: String, description: String,
                     price: Double, estimatedPrepTime: Double, image: UIImage) {

        guard let shop = currentShop else {
            print("No current shop!")
            return
        }

        let product = Product(id: oldProductId,
                              name: name,
                              shopName: shop.name,
                              shopId: shop.id,
                              description: description,
                              price: price,
                              imageURL: "",
                              estimatedPrepTime: estimatedPrepTime,
                              isOutOfStock: false,
                              options: [])

        DatabaseInterface.db.editProduct(shopId: shop.id, product: product, imageData: image.pngData())
    }

    func deleteProduct(at positions: IndexSet) {
        for index in positions {
            guard let shopId = currentShop?.id else {
                return
            }
            let idToDelete = products[index].id
            DatabaseInterface.db.deleteProduct(shopId: shopId,
                                               productId: idToDelete)
        }
        products.remove(atOffsets: positions)
    }

    func setOrderReady(orderId: String) {
        let filteredOrder = self.orders.filter { order in
            order.id == orderId
        }

        guard filteredOrder.count == 1 else {
            fatalError("The order id \(orderId) does not appear in order")
        }

        let order = filteredOrder[0]

        let editedOrder = Order(id: order.id,
                                orderProducts: order.orderProducts,
                                status: .ready,
                                customerId: order.customerId,
                                shopId: order.shopId,
                                shopName: order.shopName,
                                date: order.date,
                                collectionNo: order.collectionNo,
                                total: order.total)

        DatabaseInterface.db.editOrder(order: editedOrder)
    }

    func setOrderCollected(orderId: String) {
        let filteredOrder = self.orders.filter { order in
            order.id == orderId
        }

        guard filteredOrder.count == 1 else {
            fatalError("The order id \(orderId) does not appear in order")
        }

        let order = filteredOrder[0]

        let editedOrder = Order(id: order.id,
                                orderProducts: order.orderProducts,
                                status: .collected,
                                customerId: order.customerId,
                                shopId: order.shopId,
                                shopName: order.shopName,
                                date: order.date,
                                collectionNo: order.collectionNo,
                                total: order.total)

        DatabaseInterface.db.editOrder(order: editedOrder)

    }

    // MARK: Private functions
    private func initialiseShop(_ vendorId: String) {
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

    private func getOrders(_ shopId: String) {
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

    private func resolveErrors(_ error: Error?) -> Bool {
        if let error = error {
            print("there was an error: \(error.localizedDescription)")
            return false
        }
        return true
    }
}
