struct OrderProductSchema: Codable {
    var id: String
    var quantity: Int
    var status: OrderStatus

    var productName: String
    var productPrice: Double
    var productImageURL: String
    var productOptionChoices: [ProductOptionChoice]? = []

    var shopName: String

    var productId: String
    var shopId: String

    init(orderProduct: OrderProduct) {
        self.id = orderProduct.id.strVal
        self.quantity = orderProduct.quantity
        self.status = orderProduct.status
        self.productName = orderProduct.productName
        self.productPrice = orderProduct.productPrice
        self.productImageURL = orderProduct.productImageURL
        self.productOptionChoices = orderProduct.productOptionChoices
        self.shopName = orderProduct.shopName
        self.productId = orderProduct.productId.strVal
        self.shopId = orderProduct.shopId.strVal
    }

    func toOrderProduct() -> OrderProduct {
        OrderProduct(id: ID(strVal: self.id),
                     quantity: self.quantity,
                     status: self.status,
                     productName: self.productName,
                     productPrice: self.productPrice,
                     productImageURL: self.productImageURL,
                     productOptionChoices: self.productOptionChoices ?? [],
                     shopName: self.shopName,
                     productId: ID(strVal: self.productId),
                     shopId: ID(strVal: self.shopId))
    }
}
