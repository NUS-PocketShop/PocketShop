struct ID: Hashable, Codable, CustomStringConvertible {
    var strVal: String

    var description: String { strVal }
}
