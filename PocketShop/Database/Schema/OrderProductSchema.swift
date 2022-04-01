struct OrderProductSchema: Codable {
    var id: String
    var quantity: Int
    var status: OrderStatus

    var productName: String
    var productPrice: Double
    var productImageURL: String
    var productOptionChoices: [Int: ProductOptionChoice]? = [:]

    var productId: String
    var shopId: String

    init(orderProduct: OrderProduct) {
        self.id = orderProduct.id
        self.quantity = orderProduct.quantity
        self.status = orderProduct.status
        self.productName = orderProduct.productName
        self.productPrice = orderProduct.productPrice
        self.productImageURL = orderProduct.productImageURL
        self.productId = orderProduct.productId
        self.shopId = orderProduct.shopId

        var counter = 0
        for productOptionChoice in orderProduct.productOptionChoices {
            self.productOptionChoices?[counter] = productOptionChoice
            counter += 1
        }
    }

    func toOrderProduct() -> OrderProduct {
        let productOptionChoices = Array((self.productOptionChoices ?? [:]).values)
        return OrderProduct(id: self.id,
                            quantity: self.quantity,
                            status: self.status,
                            total: self.productPrice * Double(self.quantity),
                            productName: self.productName,
                            productPrice: self.productPrice,
                            productImageURL: self.productImageURL,
                            productOptionChoices: productOptionChoices,
                            productId: self.productId, shopId: self.shopId)
    }
}
