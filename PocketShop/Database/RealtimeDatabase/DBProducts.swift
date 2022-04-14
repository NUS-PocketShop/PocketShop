import Firebase

class DBProducts {
    func createProduct(shopId: String, product: Product, imageData: Data?) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shopId)/soldProducts").childByAutoId()
        guard let key = ref.key else {
            print("Unexpected error")
            return
        }
        uploadProduct(product: product, newId: key, imageData: imageData, ref: ref)
    }

    func editProduct(shopId: String, product: Product, imageData: Data?) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shopId)/soldProducts/\(product.id)")
        uploadProduct(product: product, newId: nil, imageData: imageData, ref: ref)
    }

    private func uploadProduct(product: Product, newId: String?, imageData: Data?, ref: DatabaseReference) {
        var newProduct = product
        if let newId = newId {
            newProduct.id = newId
        }
        let encodeAndUploadProduct = {
            let productSchema = ProductSchema(product: newProduct)
            do {
                let jsonData = try JSONEncoder().encode(productSchema)
                let json = try JSONSerialization.jsonObject(with: jsonData)
                ref.setValue(json)
            } catch {
                print(error)
            }
        }

        if let imageData = imageData {
            DatabaseInterface.db.uploadProductImage(productId: newProduct.id, imageData: imageData) { _, url in
                if let url = url {
                    newProduct.imageURL = url
                }
                encodeAndUploadProduct()
            }
        } else {
            encodeAndUploadProduct()
        }
    }

    func deleteProduct(shopId: String, productId: String) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shopId)/soldProducts/\(productId)")
        ref.removeValue { error, _ in
            if let error = error {
                print(error)
            }
        }
    }

    func setProductToOutOfStock(shopId: String, productId: String) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shopId)/soldProducts/\(productId)/isOutOfStock")
        ref.setValue(true)
    }

    func setProductToInStock(shopId: String, productId: String) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shopId)/soldProducts/\(productId)/isOutOfStock")
        ref.setValue(false)
    }

    func setAllProductsInShopToInStock(shopId: String) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shopId)/soldProducts")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let products = snapshot.value as? NSDictionary,
                  let productIds = products.allKeys as? [String] else {
                return
            }
            for productId in productIds {
                self.setProductToOutOfStock(shopId: shopId, productId: productId)
            }
        }
    }

    func setProductTags(shopId: String, productId: String, tags: [ProductTag]) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shopId)/soldProducts/\(productId)/tags")
        do {
            let jsonData = try JSONEncoder().encode(tags)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func observeAllProducts(actionBlock: @escaping (DatabaseError?, [Product]?, DatabaseEvent?) -> Void) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let shops = snapshot.value as? NSDictionary,
                  let shopIds = shops.allKeys as? [String] else {
                return
            }
            for shopId in shopIds {
                self.observeProductsFromShop(shopId: shopId, actionBlock: actionBlock)
            }
        }
    }

    func observeProductsFromShop(shopId: String,
                                 actionBlock: @escaping (DatabaseError?, [Product]?, DatabaseEvent?) -> Void) {
        let shopRef = FirebaseManager.sharedManager.ref.child("shops/\(shopId)")

        shopRef.observeSingleEvent(of: .value) { snapshot in
            guard let shop = snapshot.value as? NSDictionary,
                  var shopName = shop["name"] as? String else {
                return
            }
            shopRef.child("name").observe(.value) { snapshot in
                if snapshot.key == "name", let newValue = snapshot.value as? String {
                    shopName = newValue
                }
                shopRef.observeSingleEvent(of: .value) { snapshot in
                    guard let shop = snapshot.value as? NSDictionary else {
                        return
                    }
                    let products = self.getProductsFromShop(shop: shop)
                    actionBlock(nil, products, .updated)
                }
            }

            shopRef.child("soldProducts").observe(.childAdded) { snapshot in
                print("added")
                if let value = snapshot.value,
                   let product = self.convertProduct(productJson: value, shopId: shopId, shopName: shopName) {
                    actionBlock(nil, [product], .added)
                }
            }

            shopRef.child("soldProducts").observe(.childChanged) { snapshot in
                print("updated")
                if let value = snapshot.value,
                   let product = self.convertProduct(productJson: value, shopId: shopId, shopName: shopName) {
                    actionBlock(nil, [product], .updated)
                }
            }

            shopRef.child("soldProducts").observe(.childRemoved) { snapshot in
                print("deleted")
                if let value = snapshot.value,
                   let product = self.convertProduct(productJson: value, shopId: shopId, shopName: shopName) {
                    actionBlock(nil, [product], .deleted)
                }
            }
        }
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

    private func getProductsFromShop(shop: NSDictionary) -> [Product]? {
        var products = [Product]()
        guard let shopId = shop["id"] as? String,
              let shopName = shop["name"] as? String,
              let productSchemas = shop["soldProducts"] as? NSDictionary else {
            return nil
        }
        for value in productSchemas.allValues {
            if let product = convertProduct(productJson: value, shopId: shopId, shopName: shopName) {
                products.append(product)
            }
        }
        return products
    }
}
