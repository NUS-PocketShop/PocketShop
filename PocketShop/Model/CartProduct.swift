struct CartProduct: Hashable, Identifiable {
    var id: String
    var quantity: Int
    var total: Double

    var productName: String
    var productPrice: Double
    var productImageURL: String
    var productOptionChoices: [ProductOptionChoice]

    // To link back to the shop/product page
    var productId: String
    var shopId: String
}

enum CartValidationError: Error {
    case productChanged
    case productDeleted
    case productOutOfStock
    case shopClosed
}
