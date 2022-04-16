struct OrderProduct: Hashable, Identifiable {
    var id: ID
    var quantity: Int
    var status: OrderStatus

    var productName: String
    var productPrice: Double
    var productImageURL: String
    var productOptionChoices: [ProductOptionChoice]

    var total: Double {
        let optionsPrice = productOptionChoices.reduce(0, { $0 + $1.cost })
        return Double(quantity) * (productPrice + optionsPrice)
    }

    var shopName: String

    // To link back to the shop/product page
    var productId: ID
    var shopId: ID
}
