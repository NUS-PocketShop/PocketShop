import Firebase

class DBUsers {
    func createCustomer(id: String) {
        let customer = Customer(id: ID(strVal: id))
        let customerSchema = CustomerSchema(customer: customer)
        do {
            let jsonData = try JSONEncoder().encode(customerSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            FirebaseManager.sharedManager.ref.child("customers/\(customer.id)").setValue(json)
        } catch {
            print(error)
        }
    }

    func createVendor(id: String) {
        let vendor = Vendor(id: ID(strVal: id))
        let vendorSchema = VendorSchema(vendor: vendor)
        do {
            let jsonData = try JSONEncoder().encode(vendorSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            FirebaseManager.sharedManager.ref.child("vendors/\(vendor.id)").setValue(json)
        } catch {
            print(error)
        }
    }

    func getUser(with id: String, completionHandler: @escaping (DatabaseError?, User?) -> Void) {
        let customerRef = FirebaseManager.sharedManager.ref.child("customers/\(id)")
        let vendorRef = FirebaseManager.sharedManager.ref.child("vendors/\(id)")
        customerRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                customerRef.observe(.value) { [self] snapshot in
                    guard let value = snapshot.value else {
                        return
                    }
                    updateCustomerSnapshot(value: value, completionHandler: completionHandler)
                }
            } else {
                vendorRef.observeSingleEvent(of: .value) { [self] snapshot in
                    if snapshot.exists(), let value = snapshot.value {
                        updateVendorSnapshot(value: value, completionHandler: completionHandler)
                    } else {
                        completionHandler(DatabaseError.userNotFound, nil)
                    }
                }
            }
        }

    }

    func setFavouriteProductIds(userId: String, favouriteProductIds: [String]) {
        let ref = FirebaseManager.sharedManager.ref.child("customers/\(userId)/favouriteProductIds")
        do {
            let jsonData = try JSONEncoder().encode(favouriteProductIds)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func setRewardPoints(userId: String, rewardPoints: Int) {
        let ref = FirebaseManager.sharedManager.ref.child("customers/\(userId)/rewardPoints")
        ref.setValue(rewardPoints)
    }

    func setCoupons(userId: String, coupons: [String: Int]) {
        let ref = FirebaseManager.sharedManager.ref.child("customers/\(userId)/couponIds")
        ref.setValue(coupons)
    }

    private func updateCustomerSnapshot(value: Any, completionHandler: @escaping (DatabaseError?, User?) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: value)
            let customerSchema = try JSONDecoder().decode(CustomerSchema.self, from: jsonData)
            let customer = customerSchema.toCustomer()
            completionHandler(nil, customer)
        } catch {
            print(error)
        }
    }

    private func updateVendorSnapshot(value: Any, completionHandler: @escaping (DatabaseError?, User?) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: value)
            let vendorSchema = try JSONDecoder().decode(VendorSchema.self, from: jsonData)
            let vendor = vendorSchema.toVendor()
            completionHandler(nil, vendor)
        } catch {
            print(error)
        }
    }
}
