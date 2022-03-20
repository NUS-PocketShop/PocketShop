import Firebase

class DBOrders {
    func createOrder(order: Order) {
        let ref = FirebaseManager.sharedManager.ref.child("orders/").childByAutoId()
        guard let key = ref.key else {
            print("Unexpected error")
            return
        }
        var newOrder = order
        newOrder.id = key
        var orderSchema = OrderSchema(order: newOrder)
        let orderProductSchemas = orderSchema.orderProductSchemas ?? [:]
        orderSchema.orderProductSchemas = [:]
        do {
            let jsonData = try JSONEncoder().encode(orderSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
        createOrderProducts(orderId: orderSchema.id, orderProductSchemas: Array(orderProductSchemas.values))
    }

    private func createOrderProducts(orderId: String, orderProductSchemas: [OrderProductSchema]) {
        for orderProductSchema in orderProductSchemas {
            let ref = FirebaseManager.sharedManager.ref.child("orders/\(orderId)/orderProductSchemas").childByAutoId()
            guard let key = ref.key else {
                print("Unexpected error")
                return
            }
            var newOrderProductSchema = orderProductSchema
            newOrderProductSchema.id = key
            do {
                let jsonData = try JSONEncoder().encode(newOrderProductSchema)
                let json = try JSONSerialization.jsonObject(with: jsonData)
                ref.setValue(json)
            } catch {
                print(error)
            }
        }
    }

    func editOrder(order: Order) {
        do {
            let ref = FirebaseManager.sharedManager.ref.child("orders/\(order.id)")
            let orderSchema = OrderSchema(order: order)
            let jsonData = try JSONEncoder().encode(orderSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func deleteOrder(id: String) {
        let ref = FirebaseManager.sharedManager.ref.child("orders/\(id)")
        ref.removeValue { error, _ in
            if let error = error {
                print(error)
            }
        }
    }

    func observeAllOrders(actionBlock: @escaping (DatabaseError?, [Order]?) -> Void) {
        FirebaseManager.sharedManager.ref.observe(DataEventType.value) { snapshot in
            var orders = [Order]()
            guard let categories = snapshot.value as? NSDictionary,
                  let allOrders = categories["orders"] as? NSDictionary else {
                actionBlock(.unexpectedError, nil)
                return
            }
            for value in allOrders.allValues {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let orderSchema = try JSONDecoder().decode(OrderSchema.self, from: jsonData)
                    let orderProducts = self
                        .getOrderProductFromSchema(orderProductSchemas: Array((orderSchema.orderProductSchemas ?? [:]).values),
                                                   snapshot: snapshot)
                    let order = orderSchema.toOrder(orderProducts: orderProducts)
                    orders.append(order)
                } catch {
                    print(error)
                }
            }
            actionBlock(nil, orders)
        }
    }

    func observeOrdersFromShop(shopId: String, actionBlock: @escaping (DatabaseError?, [Order]?) -> Void) {
        observeAllOrders { error, orders in
            let newOrders = orders?.filter { $0.shopId == shopId }
            actionBlock(error, newOrders)
        }
    }

    func observeOrdersFromCustomer(customerId: String, actionBlock: @escaping (DatabaseError?, [Order]?) -> Void) {
        observeAllOrders { error, orders in
            let newOrders = orders?.filter { $0.customerId == customerId }
            actionBlock(error, newOrders)
        }
    }

    private func getOrderProductFromSchema(orderProductSchemas: [OrderProductSchema],
                                           snapshot: DataSnapshot) -> [OrderProduct] {
        var orderProducts = [OrderProduct]()
        for orderProductSchema in orderProductSchemas {
            if let product = getProductFromSnapshot(productId: orderProductSchema.id, snapshot: snapshot) {
                let orderProduct = orderProductSchema.toOrderProduct(product: product)
                orderProducts.append(orderProduct)
            }
        }
        return orderProducts
    }

    private func getProductFromSnapshot(productId: String, snapshot: DataSnapshot) -> Product? {
        var product: Product?
        guard let categories = snapshot.value as? NSDictionary,
              let shops = categories["shops"] as? NSDictionary else {
            return nil
        }
        for case let shop as NSDictionary in shops.allValues {
            guard let shopId = shop["id"] as? String,
                  let shopName = shop["name"] as? String,
                  let productSchemas = shop["soldProducts"] as? NSDictionary else {
                      return nil
                  }
            for case let value as NSDictionary in productSchemas.allValues {
                do {
                    if let id = value["id"] as? String, id == productId {
                        let jsonData = try JSONSerialization.data(withJSONObject: value)
                        let productSchema = try JSONDecoder().decode(ProductSchema.self, from: jsonData)
                        product = productSchema.toProduct(shopId: shopId, shopName: shopName)
                    }
                } catch {
                    print(error)
                }
            }
        }
        return product
    }
}
