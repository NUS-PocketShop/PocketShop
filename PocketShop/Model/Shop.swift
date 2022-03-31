struct Shop: Hashable, Identifiable {
    var id: String
    var name: String
    var description: String
    var imageURL: String
    var isClosed: Bool
    var collectionNumber: Int = 1
    var ownerId: String
    var soldProducts: [Product]
}
