import Firebase

class DBUsers {
    func createCustomer(id: String) {
        let customer = Customer(id: id)
        do {
            let jsonData = try JSONEncoder().encode(customer)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            FirebaseManager.sharedManager.ref.child("customers/\(customer.id)").setValue(json)
        } catch {
            print(error)
        }
    }

    func createVendor(id: String) {
        let vendor = Vendor(id: id)
        do {
            let jsonData = try JSONEncoder().encode(vendor)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            FirebaseManager.sharedManager.ref.child("vendors/\(vendor.id)").setValue(json)
        } catch {
            print(error)
        }
    }

    func getUser(with id: String, completionHandler: @escaping (DatabaseError?, User?) -> Void) {
        FirebaseManager.sharedManager.ref.child("customers/\(id)").observeSingleEvent(of: .value,
                                                                                      with: { snapshot in
            if snapshot.exists(), let value = snapshot.value {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let customer = try JSONDecoder().decode(Customer.self, from: jsonData)
                    completionHandler(nil, customer)
                } catch {
                    print(error)
                }
                return
            } else {
                FirebaseManager.sharedManager.ref.child("vendors/\(id)").observeSingleEvent(of: .value,
                                                                                            with: { snapshot in
                    if snapshot.exists(), let value = snapshot.value {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: value)
                            let vendor = try JSONDecoder().decode(Vendor.self, from: jsonData)
                            completionHandler(nil, vendor)
                        } catch {
                            print(error)
                        }
                        return
                    } else {
                        completionHandler(DatabaseError.userNotFound, nil)
                        return
                    }
                })
            }
        })

    }
}
