import Firebase

class DBShop {
    func createShop(shop: Shop) {
        do {
            let ref = FirebaseManager.sharedManager.ref.child("shops/").childByAutoId()
            guard let key = ref.key else {
                print("Unexpected error")
                return
            }
            var newShop = shop
            newShop.id = key
            let shopSchema = ShopSchema(shop: newShop)
            let jsonData = try JSONEncoder().encode(shopSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func editShop(shop: Shop) {
        do {
            let ref = FirebaseManager.sharedManager.ref.child("shops/\(shop.id)")
            let shopSchema = ShopSchema(shop: shop)
            let jsonData = try JSONEncoder().encode(shopSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func observeShops(ownerId: String, actionBlock: @escaping (DatabaseError?, [Shop]?) -> Void) {
        FirebaseManager.sharedManager.ref.child("shops/").observe(DataEventType.value) { snapshot in
            var shops: [Shop] = []
            if let allShops = snapshot.value as? NSDictionary {
                for value in allShops.allValues {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value)
                        let shopSchema = try JSONDecoder().decode(ShopSchema.self, from: jsonData)
                        let shop = shopSchema.toShop()
                        if shop.ownerId == ownerId {
                            shops.append(shop)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            print(shops)
            actionBlock(nil, shops)
            return
        }
    }
}
