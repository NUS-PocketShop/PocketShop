import Combine
import SwiftUI

final class VendorViewModel: ObservableObject {

    @Published var products: [Product] = [Product]()
    @Published var vendor: Vendor?
    @Published var currentShop: Shop?
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

        DatabaseInterface.db.createShop(shop: shopToCreate) { [self] error, shop in
            if let error = error {
                print(error)
                return
            }

            guard let imageData = image.pngData(),
                  let shop = shop else {
                // should have image
                print("ERROR: either no image or no shop")
                return
            }
            DBStorage().uploadShopImage(shopId: shop.id,
                                        imageData: imageData,
                                        completionHandler: { _, _ in
                                            print("uploaded")
                                        })
        }

    }

    // MARK: Private functions
    private func getCurrentShop(_ vendorId: String) {
        DatabaseInterface.db.observeShopsByOwner(ownerId: vendorId) { [self] error, shop in
            guard resolveErrors(error) else {
                return
            }

            guard let shop = shop else {
                return
            }

            if !shop.isEmpty {
                currentShop = shop[0]
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
