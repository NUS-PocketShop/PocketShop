struct Product: Hashable, Identifiable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageURL: String
    var estimatedPrepTime: Double
    var isOutOfStock: Bool
    var options: [ProductOption]
    var tags: [ProductTag]

    var shopId: String
    var shopName: String
    var shopCategory: ShopCategory?

    // For combos
    var subProductIds: [String]

    var isComboMeal: Bool {
        !subProductIds.isEmpty
    }

    var optionChoices: [ProductOptionChoice] {
        options.flatMap { $0.optionChoices }
    }
}

struct ProductTag: Hashable, Codable {
    var tag: String
}
