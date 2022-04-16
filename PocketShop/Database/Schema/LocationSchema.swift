struct LocationSchema: Hashable, Codable {
    var id: String
    var name: String
    var address: String
    var postalCode: Int
    var imageURL: String

    init(location: Location) {
        self.id = location.id.strVal
        self.name = location.name
        self.address = location.address
        self.postalCode = location.postalCode
        self.imageURL = location.imageURL
    }

    func toLocation() -> Location {
        Location(id: ID(strVal: self.id),
                 name: self.name,
                 address: self.address,
                 postalCode: self.postalCode,
                 imageURL: self.imageURL)
    }
}
