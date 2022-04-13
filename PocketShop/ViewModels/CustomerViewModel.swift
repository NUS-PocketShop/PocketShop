import Foundation
import Combine

final class CustomerViewModel: ObservableObject {

    @Published var products: [Product] = [Product]()
    @Published var shops: [Shop] = [Shop]()
    @Published var orders: [Order] = [Order]()
    @Published var cart: [CartProduct] = [CartProduct]()
    @Published var locations: [Location] = [Location]()
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
        DatabaseInterface.auth.getCurrentUser { [self] error, user in
            guard resolveErrors(error) else {
                return
            }
            if let currentCustomer = user as? Customer {
                customer = currentCustomer
                observeOrders(customerId: currentCustomer.id)
                observeCart(customerId: currentCustomer.id)
            }
        }
        observeProducts()
        observeShops()
        observeLocations()
    }

    func deleteOrder(orderId: String) {
        DatabaseInterface.db.deleteOrder(id: orderId)
    }

    func addProductToCart(_ product: Product, quantity: Int, choices: [ProductOptionChoice]) {
        guard let customerId = customer?.id else {
            fatalError("Cannot add product to cart for unknown customer")
        }

        let cartProduct = cart.first(where: { $0.productId == product.id && $0.productOptionChoices == choices })

        if let cartProduct = cartProduct {
            DatabaseInterface.db.changeProductQuantity(userId: customerId,
                                                       cartProduct: cartProduct,
                                                       quantity: cartProduct.quantity + quantity)
        } else {
            DatabaseInterface.db.addProductToCart(userId: customerId,
                                                  product: product,
                                                  productOptionChoices: choices,
                                                  quantity: quantity)
        }
    }

    func makeOrderFromCart() -> [(CartValidationError, CartProduct)]? {
        let cartErrors = self.validateCart()
        guard cartErrors == nil else {
            return cartErrors
        }

        guard let customerId = customer?.id else {
            fatalError("Cannot make order for unknown customer")
        }

        let orderProducts = cart.map {
            $0.toOrderProduct()
        }

        let orderProductsGroups = Dictionary(grouping: orderProducts, by: { $0.shopId })

        for (shopId, orderProducts) in orderProductsGroups {
            let order = Order(id: "dummyId", orderProducts: orderProducts,
                              status: .pending, customerId: customerId, shopId: shopId,
                              shopName: orderProducts[0].shopName, date: Date(), collectionNo: 0, total: 0)
            DatabaseInterface.db.createOrder(order: order)
        }

        for cartProduct in cart {
            DatabaseInterface.db.removeProductFromCart(userId: customerId, cartProduct: cartProduct)
        }

        return nil
    }

    private func validateCart() -> [(CartValidationError, CartProduct)]? {
        var invalidCartProducts = [(CartValidationError, CartProduct)]()
        for cartProduct in self.cart {
            let products = self.products.filter({ $0.id == cartProduct.productId })
            if products.isEmpty {
                invalidCartProducts.append((.productDeleted, cartProduct))
                continue
            }
            if let invalidCartProduct = validateCartProduct(product: products[0], cartProduct: cartProduct) {
                invalidCartProducts.append(invalidCartProduct)
            }
        }
        if invalidCartProducts.isEmpty {
            return nil
        }
        return invalidCartProducts
    }

    private func validateCartProduct(product: Product,
                                     cartProduct: CartProduct) -> (CartValidationError, CartProduct)? {
        if product.name != cartProduct.productName
            || product.price != cartProduct.productPrice
            || product.imageURL != cartProduct.productImageURL {
            return (.productChanged, cartProduct)
        }
        let productOptionChoices = product.optionChoices
        for optionChoice in cartProduct.productOptionChoices {
            if !productOptionChoices.contains(optionChoice) {
                return (.productChanged, cartProduct)
            }
        }
        if product.isOutOfStock {
            return (.productOutOfStock, cartProduct)
        }
        let shops = self.shops.filter({ $0.id == product.id })
        if !shops.isEmpty, shops[0].isClosed {
            return (.shopClosed, cartProduct)
        }
        return nil
    }

    func removeCartProduct(_ cartProduct: CartProduct) {
        guard let customerId = customer?.id else {
            fatalError("Unable to remove product from cart for unknown customer")
        }

        DatabaseInterface.db.removeProductFromCart(userId: customerId, cartProduct: cartProduct)
    }
    
    func addProductToFavorites(productId: String) {
        self.customer?.favouriteProductIds.append(productId)
        guard let customer = customer else {
            return
        }
        DatabaseInterface.db.setFavoriteProductIds(userId: customer.id,
                                                   favoriteProductIds: customer.favouriteProductIds)
    }
    
    func deleteProductFromFavorites(productId: String) {
        self.customer?.favouriteProductIds.removeAll(where: {$0 == productId})
        guard let customer = customer else {
            return
        }
        DatabaseInterface.db.setFavoriteProductIds(userId: customer.id,
                                                   favoriteProductIds: customer.favouriteProductIds)
    }
    
    func addRewardPoints(points: Int) {
        self.customer?.rewardPoints += points
        guard let customer = customer else {
            return
        }
        DatabaseInterface.db.setRewardPoints(userId: customer.id,
                                             rewardPoints: customer.rewardPoints)
    }

    private func observeProducts() {
        DatabaseInterface.db.observeAllProducts { [self] error, allProducts, eventType in
            guard resolveErrors(error) else {
                return
            }
            if let allProducts = allProducts, let eventType = eventType {
                if eventType == .added || eventType == .updated {
                    for product in allProducts {
                        products.removeAll(where: { $0.id == product.id })
                        products.append(product)
                    }
                } else if eventType == .deleted {
                    for product in allProducts {
                        products.removeAll(where: { $0.id == product.id })
                    }
                }
            }
        }
    }

    private func observeShops() {
        DatabaseInterface.db.observeAllShops { [self] error, allShops, eventType in
            guard resolveErrors(error) else {
                return
            }
            if let allShops = allShops, let eventType = eventType {
                if eventType == .added || eventType == .updated {
                    for shop in allShops {
                        shops.removeAll(where: { $0.id == shop.id })
                        shops.append(shop)
                    }
                } else if eventType == .deleted {
                    for shop in allShops {
                        shops.removeAll(where: { $0.id == shop.id })
                    }
                }
            }
        }
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

    private func observeOrders(customerId: String) {
        DatabaseInterface.db.observeOrdersFromCustomer(customerId: customerId) { [self] error, allOrders, eventType in
            guard resolveErrors(error) else {
                return
            }
            if let allOrders = allOrders {
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

    private func observeCart(customerId: String) {
        DatabaseInterface.db.observeCart(userId: customerId) { [self] error, cartProducts, eventType in
            guard resolveErrors(error) else {
                return
            }
            if let cartProducts = cartProducts {
                if eventType == .added || eventType == .updated {
                    for cartProduct in cartProducts {
                        self.cart.removeAll(where: { $0.id == cartProduct.id })
                        self.cart.append(cartProduct)
                    }
                } else if eventType == .deleted {
                    for cartProduct in cartProducts {
                        self.cart.removeAll(where: { $0.id == cartProduct.id })
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
