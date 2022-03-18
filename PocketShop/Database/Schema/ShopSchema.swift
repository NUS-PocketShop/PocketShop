struct ShopSchema: Codable {
    var id: String
    var name: String
    var description: String
    var imageURL: String
    var isClosed: Bool
    var ownerId: String
    var soldProducts: [ProductSchema]?

    init(shop: Shop) {
        self.id = shop.id
        self.name = shop.name
        self.description = shop.description
        self.imageURL = shop.imageURL
        self.isClosed = shop.isClosed
        self.ownerId = shop.ownerId
        self.soldProducts = []
        for product in shop.soldProducts {
            self.soldProducts?.append(ProductSchema(product: product))
        }
    }

    func toShop() -> Shop {
        var products = [Product]()
        if let soldProducts = self.soldProducts {
            for productSchema in soldProducts {
                products.append(productSchema.toProduct(shopId: self.id, shopName: self.name))
            }
        }
        return Shop(id: self.id, name: self.name, description: self.description,
                    imageURL: self.imageURL, isClosed: self.isClosed, ownerId: self.ownerId,
                    soldProducts: products)
    }
}
