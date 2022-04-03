struct OrderProduct: Hashable, Identifiable {
    var id: String
    var quantity: Int
    var status: OrderStatus
    var total: Double

    var productName: String
    var productPrice: Double
    var productImageURL: String
    var productOptionChoices: [ProductOptionChoice]

    var shopName: String

    // To link back to the shop/product page
    var productId: String
    var shopId: String
}
