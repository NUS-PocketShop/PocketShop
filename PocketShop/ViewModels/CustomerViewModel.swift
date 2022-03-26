import Combine

final class CustomerViewModel: ObservableObject {

    @Published var products: [Product] = [Product]()
    @Published var shops: [Shop] = [Shop]()
    @Published var customer: Customer?

    @Published var searchText = ""

    var productSearchResults: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var shopSearchResults: [Shop] {
        if searchText.isEmpty {
            return shops
        } else {
            return shops.filter { shop in
                let shopProducts = shop.soldProducts
                let matchingProducts = shopProducts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                return !matchingProducts.isEmpty
            }
        }
    }

    init() {
        DatabaseInterface.auth.getCurrentUser { _, user in
            if let customer = user as? Customer {
                self.customer = customer
            }
        }
        DatabaseInterface.db.observeAllShops { error, allShops in
            if let error = error {
                print(error)
                return
            }
            if let allShops = allShops {
                self.shops.removeAll()
                self.shops = allShops
            }
        }
        DatabaseInterface.db.observeAllProducts { error, allProducts, eventType in
            if let error = error {
                print(error)
                return
            }
            if let allProducts = allProducts, let eventType = eventType {
                if eventType == .added || eventType == .updated {
                    for product in allProducts {
                        self.products.removeAll(where: { $0 == product })
                        self.products.append(product)
                    }
                } else if eventType == .deleted {
                    for product in allProducts {
                        self.products.removeAll(where: { $0 == product })
                    }
                }
            }
        }
    }
}
