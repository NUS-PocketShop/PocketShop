struct CartProduct: Hashable, Identifiable {
    var id: String
    var quantity: Int
    var total: Double

    var productName: String
    var productPrice: Double
    var productImageURL: String
    var productOptionChoices: [ProductOptionChoice]

    var shopName: String

    // To link back to the shop/product page
    var productId: String
    var shopId: String

    func toOrderProduct() -> OrderProduct {
        OrderProduct(id: id, quantity: quantity, status: .pending, total: total,
                     productName: productName, productPrice: productPrice,
                     productImageURL: productImageURL,
                     productOptionChoices: productOptionChoices, shopName: shopName,
                     productId: productId, shopId: shopId)
    }
}

enum CartValidationError: Error {
    case productChanged
    case productDeleted
    case productOutOfStock
    case shopClosed
}
