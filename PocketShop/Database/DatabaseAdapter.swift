protocol DatabaseAdapter {
    func createCustomer(customer: Customer)
    func createVendor(vendor: Vendor)
    func getUser(with id: String, completionHandler: @escaping (DatabaseError?, User?) -> Void)
    func createShop(shop: Shop)
    func editShop(shop: Shop)
    func observeShops(ownerId: String, actionBlock: @escaping (DatabaseError?, [Shop]?) -> Void)
}
