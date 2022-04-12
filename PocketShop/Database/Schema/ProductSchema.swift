struct ProductSchema: Codable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageURL: String
    var estimatedPrepTime: Double
    var isOutOfStock: Bool
    var shopCategory: ShopCategory?
    var options: [ProductOption]? = []
    var tags: [ProductTag]? = []
    var subProductIds: [String]? = []

    init(product: Product) {
        self.id = product.id
        self.name = product.name
        self.description = product.description
        self.price = product.price
        self.imageURL = product.imageURL
        self.estimatedPrepTime = product.estimatedPrepTime
        self.isOutOfStock = product.isOutOfStock
        self.shopCategory = product.shopCategory
        self.options = product.options
        self.tags = product.tags
        self.subProductIds = product.subProductIds
    }

    func toProduct(shopId: String, shopName: String) -> Product {
        Product(id: self.id,
                name: self.name,
                description: self.description,
                price: self.price,
                imageURL: self.imageURL,
                estimatedPrepTime: self.estimatedPrepTime,
                isOutOfStock: self.isOutOfStock,
                options: self.options ?? [],
                tags: self.tags ?? [],
                shopId: shopId,
                shopName: shopName,
                shopCategory: self.shopCategory,
                subProductIds: self.subProductIds ?? [])
    }
}
