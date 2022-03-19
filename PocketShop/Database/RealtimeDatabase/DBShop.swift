import Firebase

class DBShop {
    func createShop(shop: Shop) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/").childByAutoId()
        guard let key = ref.key else {
            print("Unexpected error")
            return
        }
        var newShop = shop
        newShop.id = key
        let shopSchema = ShopSchema(shop: newShop)
        do {
            let jsonData = try JSONEncoder().encode(shopSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func editShop(shop: Shop) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shop.id)")
        let shopSchema = ShopSchema(shop: shop)
        do {

            let jsonData = try JSONEncoder().encode(shopSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func deleteShop(id: String) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(id)")
        ref.removeValue() { error, _ in
            if let error = error {
                print(error)
            }
        }
    }

    func observeAllShops(actionBlock: @escaping (DatabaseError?, [Shop]?) -> Void) {
        FirebaseManager.sharedManager.ref.child("shops/").observe(DataEventType.value) { snapshot in
            var shops: [Shop] = []
            guard let allShops = snapshot.value as? NSDictionary else {
                actionBlock(.unexpectedError, nil)
                return
            }
            for value in allShops.allValues {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let shopSchema = try JSONDecoder().decode(ShopSchema.self, from: jsonData)
                    let shop = shopSchema.toShop()
                    shops.append(shop)
                } catch {
                    print(error)
                }
            }
            actionBlock(nil, shops)
        }
    }

    func observeShopsByOwner(ownerId: String, actionBlock: @escaping (DatabaseError?, [Shop]?) -> Void) {
        observeAllShops() { _, shops in
            var newShops = [Shop]()
            if let shops = shops {
                newShops = shops.filter {
                    $0.ownerId == ownerId
                }
            }
            actionBlock(nil, newShops)
        }
    }
}
