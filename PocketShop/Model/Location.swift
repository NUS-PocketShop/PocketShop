struct Location: Hashable, Codable {
    var id: ID
    var name: String
    var address: String
    var postalCode: Int
    var imageURL: String
}
