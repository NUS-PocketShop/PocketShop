import Firebase

class DBCart {
    func addProductToCart(userId: String, product: Product,
                          productOptionChoices: [ProductOptionChoice]?, quantity: Int) {
        let ref = FirebaseManager.sharedManager.ref.child("carts/\(userId)").childByAutoId()
        guard let key = ref.key else {
            print("Unexpected error")
            return
        }
        let newCartProduct = CartProduct(id: key,
                                         quantity: quantity,
                                         total: product.price * Double(quantity),
                                         productName: product.name,
                                         productPrice: product.price,
                                         productImageURL: product.imageURL,
                                         productOptionChoices: productOptionChoices ?? [],
                                         shopName: product.shopName,
                                         productId: product.id,
                                         shopId: product.shopId)
        let newCartProductSchema = CartProductSchema(cartProduct: newCartProduct)

        do {
            let jsonData = try JSONEncoder().encode(newCartProductSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func removeProductFromCart(userId: String, cartProduct: CartProduct) {
        let ref = FirebaseManager.sharedManager.ref.child("carts/\(userId)/\(cartProduct.id)")
        ref.removeValue { error, _ in
            if let error = error {
                print(error)
            }
        }
    }

    func changeProductQuantity(userId: String, cartProduct: Product, quantity: Int) {
        let ref = FirebaseManager.sharedManager.ref.child("carts/\(userId)/\(cartProduct.id)")
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                ref.child("quantity").setValue(quantity)
            }
        }
    }

    func observeCart(userId: String, actionBlock: @escaping (DatabaseError?, [CartProduct]?, DatabaseEvent?) -> Void) {
        let ref = FirebaseManager.sharedManager.ref.child("carts/\(userId)")

        ref.observe(.childAdded) { snapshot in
            if let value = snapshot.value,
               let cartProductSchema = self.convertCartProductSchema(cartProductJson: value) {
                let cartProduct = cartProductSchema.toCartProduct()
                actionBlock(nil, [cartProduct], .added)
            }
        }

        ref.observe(.childChanged) { snapshot in
            if let value = snapshot.value,
               let cartProductSchema = self.convertCartProductSchema(cartProductJson: value) {
                let cartProduct = cartProductSchema.toCartProduct()
                actionBlock(nil, [cartProduct], .updated)
            }
        }

        ref.observe(.childRemoved) { snapshot in
            if let value = snapshot.value,
               let cartProductSchema = self.convertCartProductSchema(cartProductJson: value) {
                let cartProduct = cartProductSchema.toCartProduct()
                actionBlock(nil, [cartProduct], .deleted)
            }
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
