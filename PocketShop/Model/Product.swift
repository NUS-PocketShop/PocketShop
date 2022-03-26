struct Product: Hashable, Identifiable {
    var id: String
    var name: String
    var shopName: String
    var shopId: String
    var description: String
    var price: Double
    var imageURL: String
    var estimatedPrepTime: Double
    var isOutOfStock: Bool
}
