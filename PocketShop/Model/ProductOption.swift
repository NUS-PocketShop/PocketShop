struct ProductOption: Hashable, Codable {
    var title: String
    var type: OptionType
    var options: [ProductOptionChoice]
}

struct ProductOptionChoice: Hashable, Codable {
    var description: String
    var cost: Double
}

enum OptionType: Int, Codable {
    case selectOne = 1
    case selectMultiple = 2
}
