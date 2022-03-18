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
}
