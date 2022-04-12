struct ShopSchema: Codable {
    var id: String
    var name: String
    var description: String
    var locationId: String
    var imageURL: String
    var isClosed: Bool
    var collectionNumber: Int
    var ownerId: String
    var soldProducts: [String: ProductSchema]? = [:]
    var categories: [ShopCategory]? = []

    init(shop: Shop) {
        self.id = shop.id
        self.name = shop.name
        self.description = shop.description
        self.locationId = shop.locationId
        self.imageURL = shop.imageURL
        self.isClosed = shop.isClosed
        self.collectionNumber = shop.collectionNumber
        self.ownerId = shop.ownerId
        self.soldProducts = [:]
        self.categories = shop.categories
        for product in shop.soldProducts {
            self.soldProducts?[product.id] = ProductSchema(product: product)
        }
    }

    func toShop() -> Shop {
        var products = [Product]()
        if let soldProducts = self.soldProducts {
            for productSchema in soldProducts.values {
                products.append(productSchema.toProduct(shopId: self.id, shopName: self.name))
            }
        }

        return Shop(id: self.id,
                    name: self.name,
                    description: self.description,
                    locationId: self.locationId,
                    imageURL: self.imageURL,
                    isClosed: self.isClosed,
                    collectionNumber: self.collectionNumber,
                    ownerId: self.ownerId,
                    soldProducts: products,
                    categories: self.categories ?? [])
    }
}
