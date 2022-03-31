struct ProductSchema: Codable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageURL: String
    var estimatedPrepTime: Double
    var isOutOfStock: Bool
    var options: [ProductOption]?

    init(product: Product) {
        self.id = product.id
        self.name = product.name
        self.description = product.description
        self.price = product.price
        self.imageURL = product.imageURL
        self.estimatedPrepTime = product.estimatedPrepTime
        self.isOutOfStock = product.isOutOfStock
        self.options = product.options
    }

    func toProduct(shopId: String, shopName: String) -> Product {
        Product(id: self.id, name: self.name, shopName: shopName, shopId: shopId,
                description: self.description, price: self.price, imageURL: self.imageURL,
                estimatedPrepTime: self.estimatedPrepTime, isOutOfStock: self.isOutOfStock,
                options: self.options ?? [])
    }
}
