import Foundation
import Combine

final class CustomerViewModel: ObservableObject {

    @Published var products: [Product] = [Product]()
    @Published var shops: [Shop] = [Shop]()
    @Published var orders: [Order] = [Order]()
    @Published var cart: [CartProduct] = [CartProduct]()
    @Published var locations: [Location] = [Location]()
    @Published var coupons: [Coupon] = [Coupon]()
    @Published var customer: Customer?
    @Published var searchText = ""

    init() {
        var initializing = true
        DatabaseInterface.auth.getCurrentUser { [self] error, user in
            guard resolveErrors(error) else {
                return
            }
            if let currentCustomer = user as? Customer {
                customer = currentCustomer
                if initializing {
                    observeOrders(customerId: currentCustomer.id)
                    observeCart(customerId: currentCustomer.id)
                }
                initializing = false
            }
        }
        observeProducts()
        observeShops()
        observeLocations()
        observeCoupons()
    }

    func cancelOrder(orderId: ID) {
        DatabaseInterface.db.cancelOrder(id: orderId)
    }

    func getProductFor(cartProduct: CartProduct) -> Product {
        guard let product = products.first(where: { $0.id == cartProduct.productId }) else {
            fatalError("No product \(cartProduct.productId) exists!")
        }

        return product
    }

    func addProductToCart(_ product: Product, quantity: Int, choices: [ProductOptionChoice]) {
        guard let customerId = customer?.id else {
            fatalError("Cannot add product to cart for unknown customer")
        }

        let cartProduct = cart.first(where: { $0.productId == product.id && $0.productOptionChoices == choices })

        if let cartProduct = cartProduct {
            DatabaseInterface.db.changeProductQuantity(userId: customerId, cartProduct: cartProduct,
                                                       quantity: cartProduct.quantity + quantity)
        } else {
            DatabaseInterface.db.addProductToCart(userId: customerId, product: product,
                                                  productOptionChoices: choices, quantity: quantity)
        }
    }

    func editCartProduct(_ cartProduct: CartProduct, product: Product, quantity: Int, choices: [ProductOptionChoice]) {
        guard let customerId = self.customer?.id else {
            fatalError("No customer")
        }

        DatabaseInterface.db.removeProductFromCart(userId: customerId, cartProduct: cartProduct)
        DatabaseInterface.db.addProductToCart(userId: customerId, product: product,
                                              productOptionChoices: choices, quantity: quantity)
    }

    func makeOrderFromCart(with coupon: Coupon?) -> [(CartValidationError, CartProduct)]? {
        let cartErrors = self.validateCart()
        guard cartErrors == nil else {
            return cartErrors
        }

        guard let customerId = customer?.id else {
            fatalError("Cannot make order for unknown customer")
        }

        let orderProducts = cart.map { $0.toOrderProduct() }

        let orderProductsGroups = Dictionary(grouping: orderProducts, by: { $0.shopId })

        // If it does not has coupon, we can see it as if it has applied coupon
        var hasAppliedCoupon: Bool = coupon == nil

        let maximumTotal = orderProductsGroups.reduce(0) { maxTotal, cartDict in
            max(maxTotal, getTotalPrice(orderProducts: cartDict.value))
        }

        var totalPaid: Double = 0
        for (shopId, orderProducts) in orderProductsGroups {
            var order = Order(id: ID(strVal: "dummyId"), orderProducts: orderProducts,
                              status: .pending, customerId: customerId, shopId: shopId,
                              shopName: orderProducts[0].shopName, date: Date(), collectionNo: 0)

            if !hasAppliedCoupon,
                maximumTotal == getTotalPrice(orderProducts: orderProducts),
                let coupon = coupon {

                order.couponType = coupon.couponType
                order.couponAmount = coupon.amount
                order.couponId = coupon.id

                useCoupon(couponId: coupon.id)
                hasAppliedCoupon = true
            }

            totalPaid += order.total
            DatabaseInterface.db.createOrder(order: order)
        }

        changeRewardPoints(points: Int(totalPaid))

        for cartProduct in cart {
            DatabaseInterface.db.removeProductFromCart(userId: customerId, cartProduct: cartProduct)
        }

        return nil
    }

    func getTotalPrice(orderProducts: [OrderProduct]) -> Double {
        orderProducts.reduce(0) { result, orderProduct in
            result + orderProduct.total
        }
    }

    func getTotalPrice(cartProducts: [CartProduct]) -> Double {
        cartProducts.reduce(0) { result, cartProduct in
            result + cartProduct.total
        }
    }

    func getValidCoupons(total: Double) -> [Coupon] {
        customerCoupons.filter { coupon in
            coupon.minimumOrder <= total
        }
    }

    func customerCouponCount(_ coupon: Coupon) -> Int {
        customer?.couponIds[coupon.id] ?? 0
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

    func toggleProductAsFavorites(productId: ID) {
        if favourites.contains(where: { $0.id == productId }) {
            removeProductFromFavorites(productId: productId)
        } else {
            addProductToFavorites(productId: productId)
        }
    }

    func addProductToFavorites(productId: ID) {
        self.customer?.favouriteProductIds.append(productId)
        guard let customer = customer else {
            return
        }
        DatabaseInterface.db.setFavouriteProductIds(userId: customer.id,
                                                    favouriteProductIds: customer.favouriteProductIds)
    }

    func removeProductFromFavorites(productId: ID) {
        self.customer?.favouriteProductIds.removeAll(where: { $0 == productId })
        guard let customer = customer else {
            return
        }
        DatabaseInterface.db.setFavouriteProductIds(userId: customer.id,
                                                    favouriteProductIds: customer.favouriteProductIds)
    }

    func changeRewardPoints(points: Int) {
        self.customer?.rewardPoints += points
        guard let customer = customer else {
            return
        }
        DatabaseInterface.db.setRewardPoints(userId: customer.id,
                                             rewardPoints: customer.rewardPoints)
    }

    func getLocationNameFromLocationId(locationId: ID) -> String {
        locations.first(where: { $0.id == locationId })?.name ?? ""
    }

    func getLocationNameFromProduct(product: Product) -> String {
        let shop = shops.first(where: { $0.id == product.shopId })
        return locations.first(where: { $0.id == shop?.locationId })?.name ?? ""
    }

    func getLocationNameFromShopId(shopId: ID) -> String {
        let shop = shops.first(where: { $0.id == shopId })
        return locations.first(where: { $0.id == shop?.locationId })?.name ?? ""
    }

    func buyCoupon(couponId: ID) throws {
        guard let coupon = coupons.first(where: { $0.id == couponId }),
              let customer = customer else {
            return
        }

        guard customer.rewardPoints >= coupon.rewardPointCost else {
            throw CouponValidationError.notEnoughRewardsPoint
        }

        changeRewardPoints(points: -coupon.rewardPointCost)
        changeCouponQuantity(coupon: coupon, quantity: 1)
    }

    func useCoupon(couponId: ID) {
        guard let coupon = coupons.first(where: { $0.id == couponId }) else {
            return
        }

        changeCouponQuantity(coupon: coupon, quantity: -1)
    }

    private func changeCouponQuantity(coupon: Coupon, quantity: Int) {
        guard let customer = self.customer else {
            return
        }
        var customerCoupons = customer.couponIds
        if let currentCouponCount = customerCoupons[coupon.id] {
            customerCoupons[coupon.id] = currentCouponCount + quantity
        } else {
            customerCoupons[coupon.id] = quantity
        }

        if quantity < 0 {
            customerCoupons[coupon.id] = 0
        }

        DatabaseInterface.db.setCoupons(userId: customer.id, coupons: customerCoupons)
    }
}

extension CustomerViewModel {
    // Computed properties
    var productSearchResults: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter {
                let productNameMatches = $0.name.localizedCaseInsensitiveContains(searchText)
                let productTagMatches = $0.tags.contains(where: { $0.tag.localizedCaseInsensitiveContains(searchText) })
                let productShopNameMatches = $0.shopName.localizedCaseInsensitiveContains(searchText)
                let productShopLocationNameMatches = getLocationNameFromShopId(shopId: $0.shopId)
                    .localizedCaseInsensitiveContains(searchText)
                return productNameMatches || productTagMatches
                || productShopNameMatches || productShopLocationNameMatches
            }
        }
    }

    var shopSearchResults: [Shop] {
        if searchText.isEmpty {
            return shops
        } else {
            return shops.filter { shop in
                let shopNameMatches = shop.name.localizedCaseInsensitiveContains(searchText)
                let shopAnyProductNameMatches = shop.soldProducts.contains(where: {
                    $0.name.localizedCaseInsensitiveContains(searchText)
                })
                let shopAnyProductTagMatches = shop.soldProducts.contains(where: {
                    $0.tags.contains(where: { $0.tag.localizedCaseInsensitiveContains(searchText) })
                })
                let shopLocationNameMatches = getLocationNameFromLocationId(locationId: shop.locationId)
                    .localizedCaseInsensitiveContains(searchText)
                return shopNameMatches || shopAnyProductNameMatches
                || shopAnyProductTagMatches || shopLocationNameMatches
            }
        }
    }

    var locationSearchResults: [Location] {
        if searchText.isEmpty {
            return locations
        } else {
            return locations.filter { location in
                let locationNameMatches = location.name.localizedCaseInsensitiveContains(searchText)
                let locationAnyShopMatches = shops.contains(where: {
                    $0.locationId == location.id && $0.name.localizedCaseInsensitiveContains(searchText)
                })
                let locationAnyShopProductMatches = shops.contains(where: { shop in
                    shop.locationId == location.id && shop.soldProducts.contains(where: {
                        $0.name.localizedCaseInsensitiveContains(searchText)
                        || $0.tags.contains(where: { $0.tag.localizedCaseInsensitiveContains(searchText) })
                    })
                })
                return locationNameMatches || locationAnyShopMatches || locationAnyShopProductMatches
            }
        }
    }

    var favourites: [Product] {
        guard let customer = customer else {
            return []
        }
        return products.filter { customer.favouriteProductIds.contains($0.id) }
    }

    var customerCoupons: [Coupon] {
        guard let customer = customer else {
            return []
        }

        return coupons.filter { coupon in
            customer.couponIds[coupon.id] != nil && customer.couponIds[coupon.id] != 0
        }
    }
}
