struct Shop: Hashable, Identifiable {
    var id: String
    var name: String
    var description: String
    var imageURL: String
    var isClosed: Bool
    var ownerId: String
    var soldProducts: [Product]

    static func == (lhs: Shop, rhs: Shop) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
