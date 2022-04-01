struct ProductSchema: Codable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageURL: String
    var estimatedPrepTime: Double
    var isOutOfStock: Bool
    var shopCategory: ShopCategory?
    var options: [Int: ProductOption]? = [:]

    init(product: Product) {
        self.id = product.id
        self.name = product.name
        self.description = product.description
        self.price = product.price
        self.imageURL = product.imageURL
        self.estimatedPrepTime = product.estimatedPrepTime
        self.isOutOfStock = product.isOutOfStock
        self.shopCategory = product.shopCategory

        var counter = 0
        for option in product.options {
            self.options?[counter] = option
            counter += 1
        }
    }

    func toProduct(shopId: String, shopName: String) -> Product {
        let options = Array((self.options ?? [:]).values)

        return Product(id: self.id, name: self.name, shopName: shopName, shopId: shopId,
                description: self.description, price: self.price, imageURL: self.imageURL,
                estimatedPrepTime: self.estimatedPrepTime, isOutOfStock: self.isOutOfStock,
                shopCategory: self.shopCategory, options: options)
    }
}
