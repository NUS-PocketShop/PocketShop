import SwiftUI

protocol DatabaseAdapter {
    func createCustomer(id: ID)
    func createVendor(id: ID)
    func getUser(with id: ID, completionHandler: @escaping (DatabaseError?, User?) -> Void)
    func setFavouriteProductIds(userId: ID, favouriteProductIds: [ID])
    func setRewardPoints(userId: ID, rewardPoints: Int)

    func createShop(shop: Shop, imageData: Data?)
    func editShop(shop: Shop, imageData: Data?)
    func deleteShop(id: ID)
    func openShop(id: ID)
    func closeShop(id: ID)
    func observeAllShops(actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void)
    func observeShopsByOwner(ownerId: ID,
                             actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void)

    func createProduct(shopId: ID, product: Product, imageData: Data?)
    func editProduct(shopId: ID, product: Product, imageData: Data?)
    func deleteProduct(shopId: ID, productId: ID)
    func setProductToOutOfStock(shopId: ID, productId: ID)
    func setProductToInStock(shopId: ID, productId: ID)
    func setAllProductsInShopToInStock(shopId: ID)
    func setProductTags(shopId: ID, productId: ID, tags: [ProductTag])
    func observeAllProducts(actionBlock: @escaping (DatabaseError?, [Product]?, DatabaseEvent?) -> Void)
    func observeProductsFromShop(shopId: ID,
                                 actionBlock: @escaping (DatabaseError?, [Product]?, DatabaseEvent?) -> Void)

    func createOrder(order: Order)
    func editOrder(order: Order)
    func deleteOrder(id: ID)
    func cancelOrder(id: ID)
    func observeAllOrders(actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void)
    func observeOrdersFromShop(shopId: ID,
                               actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void)
    func observeOrdersFromCustomer(customerId: ID,
                                   actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void)

    func uploadProductImage(productId: ID, imageData: Data,
                            completionHandler: @escaping (DatabaseError?, String?) -> Void)
    func getProductImage(productId: ID, completionHandler: @escaping (DatabaseError?, Data?) -> Void)
    func uploadShopImage(shopId: ID, imageData: Data,
                         completionHandler: @escaping (DatabaseError?, String?) -> Void)
    func getShopImage(shopId: ID, completionHandler: @escaping (DatabaseError?, Data?) -> Void)

    func addProductToCart(userId: ID, product: Product, productOptionChoices: [ProductOptionChoice]?, quantity: Int)
    func removeProductFromCart(userId: ID, cartProduct: CartProduct)
    func changeProductQuantity(userId: ID, cartProduct: CartProduct, quantity: Int)
    func observeCart(userId: ID, actionBlock: @escaping (DatabaseError?, [CartProduct]?, DatabaseEvent?) -> Void)

    func createLocation(location: Location)
    func deleteLocation(id: ID)
    func editLocation(location: Location)
    func observeAllLocations(actionBlock: @escaping (DatabaseError?, [Location]?, DatabaseEvent?) -> Void)
}
