import Combine
import SwiftUI

final class VendorViewModel: ObservableObject {

    @Published var vendor: Vendor?
    @Published var currentShop: Shop?
    @Published var products: [Product] = [Product]()

    var shopName: String {
        currentShop?.name ?? "My Shop"
    }

    init() {
        print("initializing vendor view model")
        DatabaseInterface.auth.getCurrentUser { [self] _, user in
            if let vendor = user as? Vendor {
                self.vendor = vendor
                getCurrentShop(vendor.id)
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
                              isOutOfStock: false)

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
                              isOutOfStock: false)

        DatabaseInterface.db.editProduct(shopId: shop.id, product: product)
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

    // MARK: Private functions
    private func getCurrentShop(_ vendorId: String) {
        DatabaseInterface.db.observeShopsByOwner(ownerId: vendorId) { [self] error, shop, eventType in
            guard resolveErrors(error) else {
                return
            }

            if let shop = shop, let eventType = eventType, !shop.isEmpty {
                if eventType == .added || eventType == .updated {
                    currentShop = shop[0]
                    products = shop[0].soldProducts
                } else if eventType == .deleted {
                    currentShop = nil
                    products = [Product]()
                }
            }
        }
    }

    private func resolveErrors(_ error: DatabaseError?) -> Bool {
        if error != nil {
            print("there was an error: \(error?.localizedDescription)")
            return false
        }
        return true
    }
}
