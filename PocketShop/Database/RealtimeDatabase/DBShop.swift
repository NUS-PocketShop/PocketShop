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
            let jsonData = try JSONEncoder().encode(newShop)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func editShop(shop: Shop) {
        do {
            let ref = FirebaseManager.sharedManager.ref.child("shops/\(shop.id)")
            let jsonData = try JSONEncoder().encode(shop)
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
                        let shop = try JSONDecoder().decode(Shop.self, from: jsonData)
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
