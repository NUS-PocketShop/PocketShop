import Foundation

/// Handles interaction with customer and cart
extension CustomerViewModel {
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

    func removeCartProduct(_ cartProduct: CartProduct) {
        guard let customerId = customer?.id else {
            fatalError("Unable to remove product from cart for unknown customer")
        }

        DatabaseInterface.db.removeProductFromCart(userId: customerId, cartProduct: cartProduct)
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
}
