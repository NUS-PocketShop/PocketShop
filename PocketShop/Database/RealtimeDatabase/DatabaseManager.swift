import Firebase

class DatabaseManager: DatabaseAdapter {
    static let sharedDatabaseManager = DatabaseManager()
    private init() {}

    let users = DBUsers()
    let shops = DBShop()
    let products = DBProducts()
    let orders = DBOrders()
    let storage = DBStorage()

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

    func editShop(shop: Shop) {
        shops.editShop(shop: shop)
    }

    func deleteShop(id: String) {
        shops.deleteShop(id: id)
    }

    func observeAllShops(actionBlock: @escaping (DatabaseError?, [Shop]?) -> Void) {
        shops.observeAllShops(actionBlock: actionBlock)
    }

    func observeShopsByOwner(ownerId: String, actionBlock: @escaping (DatabaseError?, [Shop]?) -> Void) {
        shops.observeShopsByOwner(ownerId: ownerId, actionBlock: actionBlock)
    }

    func createProduct(shopId: String, product: Product) {
        products.createProduct(shopId: shopId, product: product)
    }

    func editProduct(shopId: String, product: Product) {
        products.editProduct(shopId: shopId, product: product)
    }

    func deleteProduct(shopId: String, productId: String) {
        products.deleteProduct(shopId: shopId, productId: productId)
    }

    func observeAllProducts(actionBlock: @escaping (DatabaseError?, [Product]?) -> Void) {
        products.observeAllProducts(actionBlock: actionBlock)
    }

    func observeProductsFromShop(shopId: String, actionBlock: @escaping (DatabaseError?, [Product]?) -> Void) {
        products.observeProductsFromShop(shopId: shopId, actionBlock: actionBlock)
    }

    func createOrder(order: Order) {
        orders.createOrder(order: order)
    }

    func editOrder(order: Order) {
        orders.editOrder(order: order)
    }

    func deleteOrder(id: String) {
        orders.deleteOrder(id: id)
    }

    func observeAllOrders(actionBlock: @escaping (DatabaseError?, [Order]?) -> Void) {
        orders.observeAllOrders(actionBlock: actionBlock)
    }

    func observeOrdersFromShop(shopId: String, actionBlock: @escaping (DatabaseError?, [Order]?) -> Void) {
        orders.observeOrdersFromShop(shopId: shopId, actionBlock: actionBlock)
    }

    func observeOrdersFromCustomer(customerId: String, actionBlock: @escaping (DatabaseError?, [Order]?) -> Void) {
        orders.observeOrdersFromCustomer(customerId: customerId, actionBlock: actionBlock)
    }

    func uploadProductImage(productId: String, imageData: Data,
                            completionHandler: @escaping (DatabaseError?, String?) -> Void) {
        storage.uploadProductImage(productId: productId, imageData: imageData, completionHandler: completionHandler)
    }

    func getProductImage(productId: String, completionHandler: @escaping (DatabaseError?, Data?) -> Void) {
        storage.getProductImage(productId: productId, completionHandler: completionHandler)
    }

    func uploadShopImage(shopId: String, imageData: Data,
                         completionHandler: @escaping (DatabaseError?, String?) -> Void) {
        storage.uploadShopImage(shopId: shopId, imageData: imageData, completionHandler: completionHandler)
    }

    func getShopImage(shopId: String, completionHandler: @escaping (DatabaseError?, Data?) -> Void) {
        storage.getShopImage(shopId: shopId, completionHandler: completionHandler)
    }

}
