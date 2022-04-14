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
        print("initializing vendor view model")
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

    func createProduct(product: Product, image: UIImage) {
        guard let shop = currentShop else {
            print("No current shop!")
            return
        }

        DatabaseInterface.db.createProduct(shopId: shop.id, product: product, imageData: image.pngData())
    }

    func editProduct(newProduct: Product, image: UIImage) {
        guard let shop = currentShop else {
            print("No current shop!")
            return
        }

        DatabaseInterface.db.editProduct(shopId: shop.id, product: newProduct, imageData: image.pngData())
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

    func setProductOutOfStock(product: Product) {
        DatabaseInterface.db.setProductToOutOfStock(shopId: product.shopId, productId: product.id)
        for otherProduct in products where otherProduct.isComboMeal && otherProduct.subProductIds.contains(product.id) {
            DatabaseInterface.db.setProductToOutOfStock(shopId: product.shopId, productId: otherProduct.id)
        }
    }

    func setProductInStock(product: Product) {
        DatabaseInterface.db.setProductToInStock(shopId: product.shopId, productId: product.id)
        if product.isComboMeal {
            for subProductId in product.subProductIds {
                DatabaseInterface.db.setProductToInStock(shopId: product.shopId, productId: subProductId)
            }
        }
    }

    func setAllProductsToInStock() {
        if let currentShop = currentShop {
            DatabaseInterface.db.setAllProductsInShopToInStock(shopId: currentShop.id)
        }
    }

    func addTagToProduct(product: Product, tag: ProductTag) {
        var oldTags = product.tags
        oldTags.append(tag)
        DatabaseInterface.db.setProductTags(shopId: product.shopId, productId: product.id, tags: oldTags)
    }

    func deleteTagFromProduct(product: Product, tag: ProductTag) {
        var oldTags = product.tags
        oldTags.removeAll(where: { $0 == tag })
        DatabaseInterface.db.setProductTags(shopId: product.shopId, productId: product.id, tags: oldTags)
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

    func deleteOrder(orderId: String) {
        DatabaseInterface.db.deleteOrder(id: orderId)
    }

    func setOrderAccept(orderId: String) {
        setOrderStatus(orderId: orderId, status: .accepted)
    }

    func setOrderReady(orderId: String) {
        setOrderStatus(orderId: orderId, status: .ready)
    }

    func setOrderCollected(orderId: String) {
        setOrderStatus(orderId: orderId, status: .collected)
    }

    func getLocationIdFromName(locationName: String) -> String {
        locations.first(where: { $0.name == locationName })?.id ?? ""
    }

    func getLocationNameFromId(locationId: String) -> String {
        locations.first(where: { $0.id == locationId })?.name ?? ""
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

    private func setOrderStatus(orderId: String, status: OrderStatus) {
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
                                collectionNo: order.collectionNo,
                                total: order.total)

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
