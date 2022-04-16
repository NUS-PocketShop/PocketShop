extension CustomerViewModel {
    func observeProducts() {
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

    func observeShops() {
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

    func observeLocations() {
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

    func observeCoupons() {
        DatabaseInterface.db.observeAllCoupons { [self] error, allCoupons, eventType in
            guard resolveErrors(error) else {
                return
            }
            if let allCoupons = allCoupons, let eventType = eventType {
                if eventType == .added || eventType == .updated {
                    for coupon in allCoupons {
                        coupons.removeAll(where: { $0.id == coupon.id })
                        coupons.append(coupon)
                    }
                } else if eventType == .deleted {
                    for coupon in allCoupons {
                        coupons.removeAll(where: { $0.id == coupon.id })
                    }
                }
            }
        }
    }

    func observeOrders(customerId: ID) {
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

    func observeCart(customerId: ID) {
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

    func resolveErrors(_ error: Error?) -> Bool {
        if let error = error {
            print("there was an error: \(error.localizedDescription)")
            return false
        }
        return true
    }
}
