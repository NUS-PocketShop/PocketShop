struct Shop: Hashable, Identifiable {
    var id: String
    var name: String
    var description: String
    var locationId: String
    var imageURL: String
    var isClosed: Bool
    var collectionNumber: Int = 1
    var ownerId: String
    var soldProducts: [Product]
    var categories: [ShopCategory]
    var tags: [ShopTag]
}

struct ShopCategory: Hashable, Codable {
    var title: String
}

struct ShopTag: Hashable, Codable {
    var tag: String
}
