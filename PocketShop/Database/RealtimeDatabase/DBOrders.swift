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

        let collectionNumberRef = FirebaseManager.sharedManager.ref.child("shops/\(newOrder.shopId)/collectionNumber")
        collectionNumberRef.observeSingleEvent(of: .value) { [self] snapshot in
            if let colNum = snapshot.value as? Int {
                newOrder.collectionNo = colNum
                collectionNumberRef.setValue(colNum + 1)
            }

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
            self.createOrderProducts(orderId: orderSchema.id, orderProductSchemas: Array(orderProductSchemas.values))
        }
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
        let ref = FirebaseManager.sharedManager.ref.child("orders/\(order.id)")
        var orderSchema = OrderSchema(order: order)
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

    func deleteOrder(id: String) {
        let ref = FirebaseManager.sharedManager.ref.child("orders/\(id)")
        ref.removeValue { error, _ in
            if let error = error {
                print(error)
            }
        }
    }

    func observeAllOrders(actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void) {
        let orderRef = FirebaseManager.sharedManager.ref.child("orders")

        orderRef.observe(.childAdded) { snapshot in
            print("added")
            if let value = snapshot.value, let order = self.convertOrder(orderJson: value) {
                actionBlock(nil, [order], .added)
            }
        }

        orderRef.observe(.childChanged) { snapshot in
            print("updated")
            if let value = snapshot.value, let order = self.convertOrder(orderJson: value) {
                actionBlock(nil, [order], .updated)
            }
        }
        orderRef.observe(.childRemoved) { snapshot in
            print("deleted")
            if let value = snapshot.value, let order = self.convertOrder(orderJson: value) {
                actionBlock(nil, [order], .deleted)
            }
        }

    }

    func observeOrdersFromShop(shopId: String,
                               actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void) {
        observeAllOrders { error, orders, eventType in
            let newOrders = orders?.filter { $0.shopId == shopId }
            actionBlock(error, newOrders, eventType)
        }
    }

    func observeOrdersFromCustomer(customerId: String,
                                   actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void) {
        observeAllOrders { error, orders, eventType in
            let newOrders = orders?.filter { $0.customerId == customerId }
            actionBlock(error, newOrders, eventType)
        }
    }

    private func convertOrder(orderJson: Any) -> Order? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: orderJson)
            let orderSchema = try JSONDecoder().decode(OrderSchema.self, from: jsonData)
            let order = orderSchema.toOrder()
            return order
        } catch {
            print(error)
            return nil
        }
    }
}
