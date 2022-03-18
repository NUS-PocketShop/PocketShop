protocol DatabaseAdapter {
    func createCustomer(customer: Customer)
    func createVendor(vendor: Vendor)
    func getUser(with id: String, completionHandler: @escaping (DatabaseError?, User?) -> Void)
    
    func createShop(shop: Shop)
    func editShop(shop: Shop)
    func deleteShop(id: String)
    func observeAllShops(actionBlock: @escaping (DatabaseError?, [Shop]?) -> Void)
    func observeShopsByOwner(ownerId: String, actionBlock: @escaping (DatabaseError?, [Shop]?) -> Void)
    
    func createProduct(shopId: String, product: Product)
    func editProduct(shopId: String, product: Product)
    func deleteProduct(shopId: String, productId: String)
    func observeAllProducts(actionBlock: @escaping (DatabaseError?, [Product]?) -> Void)
    func observeProductsFromShop(shopId: String, actionBlock: @escaping (DatabaseError?, [Product]?) -> Void)
}
