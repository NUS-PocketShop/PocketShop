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
    var categoryOrderingIndex: Int? = 0
    var subProductIds: [String]? = []

    init(product: Product) {
        self.id = product.id.strVal
        self.name = product.name
        self.description = product.description
        self.price = product.price
        self.imageURL = product.imageURL
        self.estimatedPrepTime = product.estimatedPrepTime
        self.isOutOfStock = product.isOutOfStock
        self.shopCategory = product.shopCategory
        self.options = product.options
        self.tags = product.tags
        self.categoryOrderingIndex = product.categoryOrderingIndex
        self.subProductIds = product.subProductIds.map({ $0.strVal })
    }

    func toProduct(shopId: String, shopName: String) -> Product {
        Product(id: ID(strVal: self.id),
                name: self.name,
                description: self.description,
                price: self.price,
                imageURL: self.imageURL,
                estimatedPrepTime: self.estimatedPrepTime,
                isOutOfStock: self.isOutOfStock,
                options: self.options ?? [],
                tags: self.tags ?? [],
                shopId: ID(strVal: shopId),
                shopName: shopName,
                shopCategory: self.shopCategory,
                categoryOrderingIndex: self.categoryOrderingIndex ?? 0,
                subProductIds: (self.subProductIds ?? []).map({ ID(strVal: $0) }))
    }
}
