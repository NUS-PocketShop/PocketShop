class DatabaseManager: DatabaseAdapter {
    static let sharedDatabaseManager = DatabaseManager()
    private init() {}

    let users = DBUsers()

    func createCustomer(customer: Customer) {
        users.createCustomer(id: customer.id)
    }

    func getCustomer(with id: String, completionHandler: @escaping (DatabaseError?, Customer?) -> Void) {
        users.getCustomer(with: id, completionHandler: completionHandler)
    }

}
