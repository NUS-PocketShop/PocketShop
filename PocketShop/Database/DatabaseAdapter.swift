protocol DatabaseAdapter {
    func createCustomer(customer: Customer)
    func createVendor(vendor: Vendor)
    func getUser(with id: String, completionHandler: @escaping (DatabaseError?, User?) -> Void)
    func createShop(shop: Shop)
}
