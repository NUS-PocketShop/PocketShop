struct Shop: Hashable, Identifiable {
    var id: ID
    var name: String
    var description: String
    var locationId: ID
    var imageURL: String
    var isClosed: Bool
    var collectionNumber: Int = 1
    var ownerId: ID
    var soldProducts: [Product]
    var categories: [ShopCategory]
}

struct ShopCategory: Hashable, Codable {
    var title: String
}
