class DatabaseManager: DatabaseAdapter {
    static let sharedDatabaseManager = DatabaseManager()
    private init() {}

    let users = DBUsers()
    let shops = DBShop()

    func createCustomer(customer: Customer) {
        users.createCustomer(customer: customer)
    }

    func createVendor(vendor: Vendor) {
        users.createVendor(vendor: vendor)
    }

    func getUser(with id: String, completionHandler: @escaping (DatabaseError?, User?) -> Void) {
        users.getUser(with: id, completionHandler: completionHandler)
    }

    func createShop(shop: Shop) {
        shops.createShop(shop: shop)
    }

}
