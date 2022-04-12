import SwiftUI

protocol DatabaseAdapter {
    func createCustomer(id: String)
    func createVendor(id: String)
    func getUser(with id: String, completionHandler: @escaping (DatabaseError?, User?) -> Void)
    func setFavoriteProductIds(userId: String, favoriteProductIds: [String])
    func setRewardPoints(userId: String, rewardPoints: Int)

    func createShop(shop: Shop, imageData: Data?)
    func editShop(shop: Shop, imageData: Data?)
    func deleteShop(id: String)
    func openShop(id: String)
    func closeShop(id: String)
    func observeAllShops(actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void)
    func observeShopsByOwner(ownerId: String,
                             actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void)

    func createProduct(shopId: String, product: Product, imageData: Data?)
    func editProduct(shopId: String, product: Product, imageData: Data?)
    func deleteProduct(shopId: String, productId: String)
    func setProductToOutOfStock(shopId: String, productId: String)
    func setProductToInStock(shopId: String, productId: String)
    func setAllProductsInShopToInStock(shopId: String)
    func observeAllProducts(actionBlock: @escaping (DatabaseError?, [Product]?, DatabaseEvent?) -> Void)
    func observeProductsFromShop(shopId: String,
                                 actionBlock: @escaping (DatabaseError?, [Product]?, DatabaseEvent?) -> Void)

    func createOrder(order: Order)
    func editOrder(order: Order)
    func deleteOrder(id: String)
    func observeAllOrders(actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void)
    func observeOrdersFromShop(shopId: String,
                               actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void)
    func observeOrdersFromCustomer(customerId: String,
                                   actionBlock: @escaping (DatabaseError?, [Order]?, DatabaseEvent?) -> Void)

    func uploadProductImage(productId: String, imageData: Data,
                            completionHandler: @escaping (DatabaseError?, String?) -> Void)
    func getProductImage(productId: String, completionHandler: @escaping (DatabaseError?, Data?) -> Void)
    func uploadShopImage(shopId: String, imageData: Data,
                         completionHandler: @escaping (DatabaseError?, String?) -> Void)
    func getShopImage(shopId: String, completionHandler: @escaping (DatabaseError?, Data?) -> Void)

    func addProductToCart(userId: String, product: Product, productOptionChoices: [ProductOptionChoice]?, quantity: Int)
    func removeProductFromCart(userId: String, cartProduct: CartProduct)
    func changeProductQuantity(userId: String, cartProduct: CartProduct, quantity: Int)
    func observeCart(userId: String, actionBlock: @escaping (DatabaseError?, [CartProduct]?, DatabaseEvent?) -> Void)
}
