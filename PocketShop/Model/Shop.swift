struct Shop: Codable, Hashable {
    var id: String
    var name: String
    var description: String
    var imageURL: String
    var isClosed: Bool
    var ownerId: String
    var soldProducts: [Product]
}
