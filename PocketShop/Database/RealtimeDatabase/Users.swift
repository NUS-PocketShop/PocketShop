import Firebase

class Users {
    func createCustomer(id: String) {
        FirebaseManager.sharedManager.ref.child("customers").setValue(id)
    }
}
