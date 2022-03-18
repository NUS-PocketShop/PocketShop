import Firebase

class DBUsers {
    func createCustomer(customer: Customer) {
        do {
            let jsonData = try JSONEncoder().encode(customer)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            FirebaseManager.sharedManager.ref.child("customers/\(customer.id)").setValue(json)
        } catch {
            print(error)
        }
    }

    func createVendor(vendor: Vendor) {
        do {
            let jsonData = try JSONEncoder().encode(vendor)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            FirebaseManager.sharedManager.ref.child("vendors/\(vendor.id)").setValue(json)
        } catch {
            print(error)
        }
    }

    func getUser(with id: String, completionHandler: @escaping (DatabaseError?, User?) -> Void) {
        FirebaseManager.sharedManager.ref.child("customers/\(id)").observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [String: Any] {
                let customer = Customer(id: id)
                completionHandler(nil, customer)
                return
            }
            FirebaseManager.sharedManager.ref.child("vendors/\(id)").observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? [String: Any] {
                    let vendor = Vendor(id: id)
                    completionHandler(nil, vendor)
                    return
                }
                completionHandler(DatabaseError.userNotFound, nil)
                return
            })
        })

    }
}
