import Combine

final class CustomerViewModel: ObservableObject {

    @Published var products: [Product] = [Product]()
    @Published var shops: [Shop] = [Shop]()
    @Published var orders: [Order] = [Order]()
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
                self.observeOrders(customerId: customer.id)
            }
        }
        observeProducts()
        observeShops()
    }

    private func observeProducts() {
        DatabaseInterface.db.observeAllProducts { error, allProducts, eventType in
            if let error = error {
                print(error)
                return
            }
            if let allProducts = allProducts, let eventType = eventType {
                if eventType == .added || eventType == .updated {
                    for product in allProducts {
                        self.products.removeAll(where: { $0.id == product.id })
                        self.products.append(product)
                    }
                } else if eventType == .deleted {
                    for product in allProducts {
                        self.products.removeAll(where: { $0.id == product.id })
                    }
                }
            }
        }
    }

    private func observeShops() {
        DatabaseInterface.db.observeAllShops { error, allShops, eventType in
            if let error = error {
                print(error)
                return
            }
            if let allShops = allShops, let eventType = eventType {
                if eventType == .added || eventType == .updated {
                    for shop in allShops {
                        self.shops.removeAll(where: { $0.id == shop.id })
                        self.shops.append(shop)
                    }
                } else if eventType == .deleted {
                    for shop in allShops {
                        self.shops.removeAll(where: { $0.id == shop.id })
                    }
                }
            }
        }
    }

    private func observeOrders(customerId: String) {
        DatabaseInterface.db.observeOrdersFromCustomer(customerId: customerId) { _, allOrders, eventType in
            guard let allOrders = allOrders else {
                fatalError("Something wrong when listening to orders")
            }
            if eventType == .added || eventType == .updated {
                for order in allOrders {
                    self.orders.removeAll(where: { $0.id == order.id })
                    self.orders.append(order)
                }
            } else if eventType == .deleted {
                for order in allOrders {
                    self.orders.removeAll(where: { $0.id == order.id })
                }
            }
        }
    }
}
