struct Product {
    var id: String
    var name: String
    var shopName: String
    var description: String
    var price: Double
    var imageURL: String
    var estimatedPrepTime: Double
    var isOutOfStock: Bool
}

extension Product: Hashable {

}
