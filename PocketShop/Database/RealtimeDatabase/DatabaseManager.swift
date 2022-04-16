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

    func createCustomer(id: ID) {
        users.createCustomer(id: id.strVal)
    }

    func createVendor(id: ID) {
        users.createVendor(id: id.strVal)
    }

    func getUser(with id: ID, completionHandler: @escaping (DatabaseError?, User?) -> Void) {
        users.getUser(with: id.strVal, completionHandler: completionHandler)
    }

    func setFavouriteProductIds(userId: ID, favouriteProductIds: [ID]) {
        users.setFavouriteProductIds(userId: userId.strVal, favouriteProductIds: favouriteProductIds.map({ $0.strVal }))
    }

    func setRewardPoints(userId: ID, rewardPoints: Int) {
        users.setRewardPoints(userId: userId.strVal, rewardPoints: rewardPoints)
    }

    func createShop(shop: Shop, imageData: Data?) {
        shops.createShop(shop: shop, imageData: imageData)
    }

    func editShop(shop: Shop, imageData: Data?) {
        shops.editShop(shop: shop, imageData: imageData)
    }

    func deleteShop(id: ID) {
        shops.deleteShop(id: id.strVal)
    }

    func openShop(id: ID) {
        shops.openShop(id: id.strVal)
    }

    func closeShop(id: ID) {
        shops.closeShop(id: id.strVal)
    }

    func observeAllShops(actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void) {
        shops.observeAllShops(actionBlock: actionBlock)
    }

    func observeShopsByOwner(ownerId: ID,
                             actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void) {
        shops.observeShopsByOwner(ownerId: ownerId.strVal, actionBlock: actionBlock)
    }

    func createProduct(shopId: ID, product: Product, imageData: Data?) {
        products.createProduct(shopId: shopId.strVal, product: product, imageData: imageData)
    }

    func editProduct(shopId: ID, product: Product, imageData: Data?) {
        products.editProduct(shopId: shopId.strVal, product: product, imageData: imageData)
    }

    func deleteProduct(shopId: ID, productId: ID) {
        products.deleteProduct(shopId: shopId.strVal, productId: productId.strVal)
    }

    func setProductToOutOfStock(shopId: ID, productId: ID) {
        products.setProductToOutOfStock(shopId: shopId.strVal, productId: productId.strVal)
    }

    func setProductToInStock(shopId: ID, productId: ID) {
        products.setProductToInStock(shopId: shopId.strVal, productId: productId.strVal)
    }

    func setAllProductsInShopToInStock(shopId: ID) {
        products.setAllProductsInShopToInStock(shopId: shopId.strVal)
    }

    func setProductTags(shopId: ID, productId: ID, tags: [ProductTag]) {
        products.setProductTags(shopId: shopId.strVal, productId: productId.strVal, tags: tags)
    }

    func observeAllProducts(actionBlock: @escaping (DatabaseError?, [Product]?, DatabaseEvent?) -> Void) {
        products.observeAllProducts(actionBlock: actionBlock)
    }

    func observeProductsFromShop(shopId: ID,
                                 actionBlock: @escaping (DatabaseError?, [Product]?, DatabaseEvent?) -> Void) {
        products.observeProductsFromShop(shopId: shopId.strVal, actionBlock: actionBlock)
    }

    func createOrder(order: Order) {
        orders.createOrder(order: order)
    }

    func editOrder(order: Order) {
        orders.editOrder(order: order)
    }

    func deleteOrder(id: ID) {
        orders.deleteOrder(id: id.strVal)
    }

    func cancelOrder(id: ID) {
        orders.cancelOrder(id: id.strVal)
    }

    func observeAllOrders(actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void) {
        orders.observeAllOrders(actionBlock: actionBlock)
    }

    func observeOrdersFromShop(shopId: ID,
                               actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void) {
        orders.observeOrdersFromShop(shopId: shopId.strVal, actionBlock: actionBlock)
    }

    func observeOrdersFromCustomer(customerId: ID,
                                   actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void) {
        orders.observeOrdersFromCustomer(customerId: customerId.strVal, actionBlock: actionBlock)
    }

    func uploadProductImage(productId: ID, imageData: Data,
                            completionHandler: @escaping (DatabaseError?, String?) -> Void) {
        storage.uploadProductImage(productId: productId.strVal,
                                   imageData: imageData, completionHandler: completionHandler)
    }

    func getProductImage(productId: ID, completionHandler: @escaping (DatabaseError?, Data?) -> Void) {
        storage.getProductImage(productId: productId.strVal, completionHandler: completionHandler)
    }

    func uploadShopImage(shopId: ID, imageData: Data,
                         completionHandler: @escaping (DatabaseError?, String?) -> Void) {
        storage.uploadShopImage(shopId: shopId.strVal, imageData: imageData, completionHandler: completionHandler)
    }

    func getShopImage(shopId: ID, completionHandler: @escaping (DatabaseError?, Data?) -> Void) {
        storage.getShopImage(shopId: shopId.strVal, completionHandler: completionHandler)
    }

    func addProductToCart(userId: ID, product: Product,
                          productOptionChoices: [ProductOptionChoice]?, quantity: Int) {
        cart.addProductToCart(userId: userId.strVal, product: product,
                              productOptionChoices: productOptionChoices, quantity: quantity)
    }

    func removeProductFromCart(userId: ID, cartProduct: CartProduct) {
        cart.removeProductFromCart(userId: userId.strVal, cartProduct: cartProduct)
    }

    func changeProductQuantity(userId: ID, cartProduct: CartProduct, quantity: Int) {
        cart.changeProductQuantity(userId: userId.strVal, cartProduct: cartProduct, quantity: quantity)
    }

    func observeCart(userId: ID, actionBlock: @escaping (DatabaseError?, [CartProduct]?, DatabaseEvent?) -> Void) {
        cart.observeCart(userId: userId.strVal, actionBlock: actionBlock)
    }

    func createLocation(location: Location) {
        locations.createLocation(location: location)
    }

    func deleteLocation(id: ID) {
        locations.deleteLocation(id: id.strVal)
    }

    func editLocation(location: Location) {
        locations.editLocation(location: location)
    }

    func observeAllLocations(actionBlock: @escaping (DatabaseError?, [Location]?, DatabaseEvent?) -> Void) {
        locations.observeAllLocations(actionBlock: actionBlock)
    }

}
