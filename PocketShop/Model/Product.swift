struct Product: Hashable, Identifiable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageURL: String
    var estimatedPrepTime: Double
    var isOutOfStock: Bool
    var options: [ProductOption]
    
    var shopId: String
    var shopName: String
    var shopCategory: ShopCategory?
    
    // For combos
    var subProducts: [Product]
    

    var optionChoices: [ProductOptionChoice] {
        options.flatMap { $0.optionChoices }
    }
}
