import Firebase

class DBShop {
    func createShop(shop: Shop, imageData: Data?) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/").childByAutoId()
        guard let key = ref.key else {
            print("Unexpected error")
            return
        }
        uploadShop(shop: shop, newId: key, imageData: imageData, ref: ref)
    }

    func editShop(shop: Shop, imageData: Data?) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(shop.id)")
        uploadShop(shop: shop, newId: nil, imageData: imageData, ref: ref)
    }
    
    private func uploadShop(shop: Shop, newId: String?, imageData: Data?, ref: DatabaseReference) {
        var newShop = shop
        if let newId = newId {
            newShop.id = newId
            newShop.soldProducts = []
        }
        
        let encodeAndUploadShop = {
            let shopSchema = ShopSchema(shop: newShop)
            do {
                let jsonData = try JSONEncoder().encode(shopSchema)
                let json = try JSONSerialization.jsonObject(with: jsonData)
                ref.setValue(json)
            } catch {
                print(error)
            }
        }

        if let imageData = imageData {
            DatabaseInterface.db.uploadShopImage(shopId: newShop.id, imageData: imageData) { _, url in
                if let url = url {
                    newShop.imageURL = url
                }
                encodeAndUploadShop()
            }
        }
        encodeAndUploadShop()
    }

    func deleteShop(id: String) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(id)")
        ref.removeValue { error, _ in
            if let error = error {
                print(error)
            }
        }
    }

    func openShop(id: String) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(id)/isClosed")
        ref.setValue(false)
    }

    func closeShop(id: String) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/\(id)/isClosed")
        ref.setValue(true)
    }

    func observeAllShops(actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void) {
        let ref = FirebaseManager.sharedManager.ref.child("shops/")
        ref.observe(.childAdded) { snapshot in
            print("added")
            if let value = snapshot.value, let shop = self.convertShop(shopJson: value) {
                actionBlock(nil, [shop], .added)
            }
        }
        ref.observe(.childChanged) { snapshot in
            print("updated")
            if let value = snapshot.value, let shop = self.convertShop(shopJson: value) {
                actionBlock(nil, [shop], .updated)
            }
        }
        ref.observe(.childRemoved) { snapshot in
            print("deleted")
            if let value = snapshot.value, let shop = self.convertShop(shopJson: value) {
                actionBlock(nil, [shop], .deleted)
            }
        }
    }

    func observeShopsByOwner(ownerId: String,
                             actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void) {
        observeAllShops { _, shops, eventType in
            var newShops = [Shop]()
            if let shops = shops {
                newShops = shops.filter {
                    $0.ownerId == ownerId
                }
            }
            actionBlock(nil, newShops, eventType)
        }
    }

    private func convertShop(shopJson: Any) -> Shop? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: shopJson)
            let shopSchema = try JSONDecoder().decode(ShopSchema.self, from: jsonData)
            let shop = shopSchema.toShop()
            return shop
        } catch {
            print(error)
            return nil
        }
    }
}
