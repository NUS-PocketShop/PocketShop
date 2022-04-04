struct Shop: Hashable, Identifiable {
    var id: String
    var name: String
    var description: String
    var location: Location
    var imageURL: String
    var isClosed: Bool
    var collectionNumber: Int = 1
    var ownerId: String
    var soldProducts: [Product]
    var categories: [ShopCategory]
    var tags: [String]
}

struct ShopCategory: Hashable, Codable {
    var title: String
}
