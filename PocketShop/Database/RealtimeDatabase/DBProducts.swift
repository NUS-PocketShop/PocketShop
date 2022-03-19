import Firebase

class DBProducts {
    func createProduct(shopId: String, product: Product) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shopId)/soldProducts").childByAutoId()
        guard let key = ref.key else {
            print("Unexpected error")
            return
        }
        var newProduct = product
        newProduct.id = key
        let productSchema = ProductSchema(product: newProduct)
        do {
            let jsonData = try JSONEncoder().encode(productSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func editProduct(shopId: String, product: Product) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shopId)/soldProducts/\(product.id)")
        let productSchema = ProductSchema(product: product)
        do {
            let jsonData = try JSONEncoder().encode(productSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func deleteProduct(shopId: String, productId: String) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shopId)/soldProducts/\(productId)")
        ref.removeValue() { error, _ in
            if let error = error {
                print(error)
            }
        }
    }

    func observeAllProducts(actionBlock: @escaping (DatabaseError?, [Product]?) -> Void) {
        var products = [Product]()
        FirebaseManager.sharedManager.ref.child("shops/").observe(DataEventType.value) { snapshot in
            guard let allShops = snapshot.value as? NSDictionary else {
                actionBlock(.unexpectedError, nil)
                return
            }
            for case let key as String in allShops.allKeys {
                self.observeProductsFromShop(shopId: key) { _, shopProducts in
                    if let shopProducts = shopProducts {
                        products.append(contentsOf: shopProducts)
                    }
                }
            }
            actionBlock(nil, products)
        }
    }

    func observeProductsFromShop(shopId: String, actionBlock: @escaping (DatabaseError?, [Product]?) -> Void) {
        var products = [Product]()
        FirebaseManager.sharedManager.ref.child("shops/\(shopId)").observe(DataEventType.value) { snapshot in
            guard let shop = snapshot.value as? NSDictionary,
                  let shopId = shop["id"] as? String,
                  let shopName = shop["name"] as? String,
                  let productSchemas = shop["soldProducts"] as? NSDictionary else {
                actionBlock(.unexpectedError, nil)
                return
            }
            for value in productSchemas.allValues {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let productSchema = try JSONDecoder().decode(ProductSchema.self, from: jsonData)
                    let product = productSchema.toProduct(shopId: shopId, shopName: shopName)
                    products.append(product)
                } catch {
                    print(error)
                }
            }
            actionBlock(nil, products)
        }
    }
}
