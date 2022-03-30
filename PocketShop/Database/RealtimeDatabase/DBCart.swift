import Firebase

class DBCart {
    func addProductToCart(userId: String, product: Product, quantity: Int) {
        let ref = FirebaseManager.sharedManager.ref.child("carts/\(userId)/\(product.id)")
        let newCartProductSchema = CartProductSchema(shopId: product.shopId,
                                                     productId: product.id, quantity: quantity)
        do {
            let jsonData = try JSONEncoder().encode(newCartProductSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func removeProductFromCart(userId: String, product: Product) {
        let ref = FirebaseManager.sharedManager.ref.child("carts/\(userId)/\(product.id)")
        ref.removeValue { error, _ in
            if let error = error {
                print(error)
            }
        }
    }

    func changeProductQuantity(userId: String, product: Product, quantity: Int) {
        let ref = FirebaseManager.sharedManager.ref.child("carts/\(userId)/\(product.id)")
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                ref.child("quantity").setValue(quantity)
            } else {
                self.addProductToCart(userId: userId, product: product, quantity: quantity)
            }
        }
    }

    func observeCart(userId: String, completionHandler: @escaping (DatabaseError?, [CartProduct]?, DatabaseEvent?) -> Void) {
        let ref = FirebaseManager.sharedManager.ref.child("carts/\(userId)")
        var cartProducts = [CartProduct]()

        // Each cart product listens for when its product is changed. If a cart product is deleted, its listener is removed by calling
        // its listener remover.
        var listenerRemovers: [String : (() -> Void)] = [:]

        ref.observe(.childAdded) { snapshot in
            if let value = snapshot.value, let cartProductSchema = self.convertCartProductSchema(cartProductJson: value) {
                let remover = self.observeProductFromId(productId: cartProductSchema.productId,
                                                        shopId: cartProductSchema.shopId) { _, product in
                    guard let product = product else {
                        return
                    }
                    let cartProductsToEdit = cartProducts.filter { $0.product.id == product.id }
                    cartProducts.removeAll() { $0.product.id == product.id }
                    if cartProductsToEdit.isEmpty {
                        let newCartProduct = CartProduct(product: product, quantity: cartProductSchema.quantity)
                        cartProducts.append(newCartProduct)
                        completionHandler(nil, [newCartProduct], .added)
                    } else {
                        var newCartProducts = [CartProduct]()
                        for cartProduct in cartProductsToEdit {
                            var newCartProduct = cartProduct
                            newCartProduct.product = product
                            newCartProducts.append(newCartProduct)
                            cartProducts.append(newCartProduct)
                        }
                        completionHandler(nil, newCartProducts, .updated)
                    }
                }
                listenerRemovers[cartProductSchema.productId] = remover
            }
        }

        ref.observe(.childChanged) { snapshot in
            if let value = snapshot.value, let cartProductSchema = self.convertCartProductSchema(cartProductJson: value) {
                let cartProductsToEdit = cartProducts.filter { $0.product.id == cartProductSchema.productId }
                cartProducts.removeAll() { $0.product.id == cartProductSchema.productId }
                var newCartProducts = [CartProduct]()
                for cartProduct in cartProductsToEdit {
                    var newCartProduct = cartProduct
                    newCartProduct.quantity = cartProduct.quantity
                    newCartProducts.append(newCartProduct)
                    cartProducts.append(newCartProduct)
                }
                completionHandler(nil, newCartProducts, .updated)
            }
        }

        ref.observe(.childRemoved) { snapshot in
            if let value = snapshot.value, let cartProductSchema = self.convertCartProductSchema(cartProductJson: value) {
                let cartProductsToDelete = cartProducts.filter { $0.product.id == cartProductSchema.productId }
                cartProducts.removeAll() { $0.product.id == cartProductSchema.productId }
                if let remover = listenerRemovers[cartProductSchema.productId] {
                    remover()
                }
                completionHandler(nil, cartProductsToDelete, .deleted)
            }
        }
    }

    private func observeProductFromId(productId: String, shopId: String,
                                      actionBlock: @escaping (DatabaseError?, Product?) -> Void) -> (() -> Void) {
        let shopRef = FirebaseManager.sharedManager.ref.child("shops/\(shopId)")
        var productHandle: DatabaseHandle?
        let shopHandle = shopRef.child("name").observe(.value) { snapshot in
            guard let shopName = snapshot.value as? String else {
                return
            }
            if let productHandle = productHandle {
                shopRef.child("/soldProducts/\(productId)").removeObserver(withHandle: productHandle)
            }
            productHandle = shopRef.child("/soldProducts/\(productId)").observe(.value) { snapshot in
                if let value = snapshot.value,
                   let product = self.convertProduct(productJson: value, shopId: shopId, shopName: shopName) {
                    actionBlock(nil, product)
                }
            }
        }

        // Function to remove listeners when the product is deleted
        let removeListener = {
            if let productHandle = productHandle {
                shopRef.child("/soldProducts/\(productId)").removeObserver(withHandle: productHandle)
            }
            shopRef.removeObserver(withHandle: shopHandle)
        }
        return removeListener
    }

    private func convertProduct(productJson: Any, shopId: String, shopName: String) -> Product? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: productJson)
            let productSchema = try JSONDecoder().decode(ProductSchema.self, from: jsonData)
            let product = productSchema.toProduct(shopId: shopId, shopName: shopName)
            return product
        } catch {
            print(error)
            return nil
        }
    }

    private func convertCartProductSchema(cartProductJson: Any) -> CartProductSchema? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: cartProductJson)
            let cartProductSchema = try JSONDecoder().decode(CartProductSchema.self, from: jsonData)
            return cartProductSchema
        } catch {
            print(error)
            return nil
        }
    }

}
