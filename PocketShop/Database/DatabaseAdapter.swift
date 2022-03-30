import SwiftUI

protocol DatabaseAdapter {
    func createCustomer(customer: Customer)
    func createVendor(vendor: Vendor)
    func getUser(with id: String, completionHandler: @escaping (DatabaseError?, User?) -> Void)

    func createShop(shop: Shop, imageData: Data?)
    func editShop(shop: Shop)
    func deleteShop(id: String)
    func observeAllShops(actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void)
    func observeShopsByOwner(ownerId: String,
                             actionBlock: @escaping (DatabaseError?, [Shop]?, DatabaseEvent?) -> Void)

    func createProduct(shopId: String, product: Product, imageData: Data?)
    func editProduct(shopId: String, product: Product, imageData: Data?)
    func deleteProduct(shopId: String, productId: String)
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
}
