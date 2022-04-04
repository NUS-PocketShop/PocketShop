import Firebase

class DBCart {
    func addProductToCart(userId: String, product: Product,
                          productOptionChoices: [ProductOptionChoice]?, quantity: Int) {
        let ref = FirebaseManager.sharedManager.ref.child("carts/\(userId)").childByAutoId()
        guard let key = ref.key else {
            print("Unexpected error")
            return
        }
        var optionsPrice: Double = 0
        if let choices = productOptionChoices {
            optionsPrice = choices.reduce(0, { $0 + $1.cost })
            print("calculating options price: \(optionsPrice)")
        }

        let newCartProduct = CartProduct(id: key,
                                         quantity: quantity,
                                         total: calculateProductTotal(price: product.price,
                                                                      quantity: Double(quantity),
                                                                      choiceCosts: optionsPrice),
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

    private func calculateProductTotal(price: Double, quantity: Double, choiceCosts: Double) -> Double {
        print("my product total is \(quantity * (price + choiceCosts))")
        return quantity * (price + choiceCosts)
    }

}
