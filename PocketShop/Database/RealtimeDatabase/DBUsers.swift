import Firebase

class DBUsers {
    func createCustomer(id: String) {
        FirebaseManager.sharedManager.ref.child("customers/\(id)/id").setValue(id)
    }

    func getCustomer(with id: String, completionHandler: @escaping (DatabaseError?, Customer?) -> Void) {
        FirebaseManager.sharedManager.ref.child("customers/\(id)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completionHandler(DatabaseError.userNotFound, nil)
                return
            }
            let customer = Customer(id: id)
            completionHandler(nil, customer)

        })

    }
}
