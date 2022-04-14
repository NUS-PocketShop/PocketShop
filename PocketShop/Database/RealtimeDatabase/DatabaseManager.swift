import Firebase
class DatabaseManager: DatabaseAdapter {
    static let sharedDatabaseManager = DatabaseManager()
    private init() {}

    let users = DBUsers()
    let shops = DBShop()
    let products = DBProducts()
    let orders = DBOrders()
    let storage = DBStorage()
    let cart = DBCart()
    let locations = DBLocation()

    func createCustomer(id: String) {
        users.createCustomer(id: id)
    }

    func createVendor(id: String) {
        users.createVendor(id: id)
    }

    func getUser(with id: String, completionHandler: @escaping (DatabaseError?, User?) -> Void) {
        users.getUser(with: id, completionHandler: completionHandler)
    }

    func setFavouriteProductIds(userId: String, favouriteProductIds: [String]) {
        users.setFavouriteProductIds(userId: userId, favouriteProductIds: favouriteProductIds)
    }

    func setRewardPoints(userId: String, rewardPoints: Int) {
        users.setRewardPoints(userId: userId, rewardPoints: rewardPoints)
    }

    func createShop(shop: Shop, imageData: Data?) {
        shops.createShop(shop: shop, imageData: imageData)
    }

    func editShop(shop: Shop, imageData: Data?) {
        shops.editShop(shop: shop, imageData: imageData)
    }

    func deleteShop(id: String) {
        shops.deleteShop(id: id)
    }

    func openShop(id: String) {
        shops.openShop(id: id)
    }

    func closeShop(id: String) {
        shops.closeShop(id: id)
    }

    func observeAllShops(actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void) {
        shops.observeAllShops(actionBlock: actionBlock)
    }

    func observeShopsByOwner(ownerId: String,
                             actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void) {
        shops.observeShopsByOwner(ownerId: ownerId, actionBlock: actionBlock)
    }

    func createProduct(shopId: String, product: Product, imageData: Data?) {
        products.createProduct(shopId: shopId, product: product, imageData: imageData)
    }

    func editProduct(shopId: String, product: Product, imageData: Data?) {
        products.editProduct(shopId: shopId, product: product, imageData: imageData)
    }

    func deleteProduct(shopId: String, productId: String) {
        products.deleteProduct(shopId: shopId, productId: productId)
    }

    func setProductToOutOfStock(shopId: String, productId: String) {
        products.setProductToOutOfStock(shopId: shopId, productId: productId)
    }

    func setProductToInStock(shopId: String, productId: String) {
        products.setProductToInStock(shopId: shopId, productId: productId)
    }

    func setAllProductsInShopToInStock(shopId: String) {
        products.setAllProductsInShopToInStock(shopId: shopId)
    }

    func setProductTags(shopId: String, productId: String, tags: [ProductTag]) {
        products.setProductTags(shopId: shopId, productId: productId, tags: tags)
    }

    func observeAllProducts(actionBlock: @escaping (DatabaseError?, [Product]?, DatabaseEvent?) -> Void) {
        products.observeAllProducts(actionBlock: actionBlock)
    }

    func observeProductsFromShop(shopId: String,
                                 actionBlock: @escaping (DatabaseError?, [Product]?, DatabaseEvent?) -> Void) {
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

    func cancelOrder(id: String) {
        orders.cancelOrder(id: id)
    }

    func observeAllOrders(actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void) {
        orders.observeAllOrders(actionBlock: actionBlock)
    }

    func observeOrdersFromShop(shopId: String,
                               actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void) {
        orders.observeOrdersFromShop(shopId: shopId, actionBlock: actionBlock)
    }

    func observeOrdersFromCustomer(customerId: String,
                                   actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void) {
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

    func addProductToCart(userId: String, product: Product,
                          productOptionChoices: [ProductOptionChoice]?, quantity: Int) {
        cart.addProductToCart(userId: userId, product: product,
                              productOptionChoices: productOptionChoices, quantity: quantity)
    }

    func removeProductFromCart(userId: String, cartProduct: CartProduct) {
        cart.removeProductFromCart(userId: userId, cartProduct: cartProduct)
    }

    func changeProductQuantity(userId: String, cartProduct: CartProduct, quantity: Int) {
        cart.changeProductQuantity(userId: userId, cartProduct: cartProduct, quantity: quantity)
    }

    func observeCart(userId: String, actionBlock: @escaping (DatabaseError?, [CartProduct]?, DatabaseEvent?) -> Void) {
        cart.observeCart(userId: userId, actionBlock: actionBlock)
    }

    func createLocation(location: Location) {
        locations.createLocation(location: location)
    }

    func deleteLocation(id: String) {
        locations.deleteLocation(id: id)
    }

    func editLocation(location: Location) {
        locations.editLocation(location: location)
    }

    func observeAllLocations(actionBlock: @escaping (DatabaseError?, [Location]?, DatabaseEvent?) -> Void) {
        locations.observeAllLocations(actionBlock: actionBlock)
    }

}
