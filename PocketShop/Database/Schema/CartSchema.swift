struct CartSchema: Codable {
    var id: String
    var customerId: String
    var products: [String: CartProductSchema]
}

struct CartProductSchema: Codable {
    var shopId: String
    var productId: String
    var quantity: Int
}
