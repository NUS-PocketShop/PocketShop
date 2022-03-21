struct OrderProductSchema: Codable {
    var id: String
    var productId: String
    var quantity: Int
    var status: OrderStatus

    init(orderProduct: OrderProduct) {
        self.id = orderProduct.id
        self.productId = orderProduct.product.id
        self.quantity = orderProduct.quantity
        self.status = orderProduct.status
    }

    func toOrderProduct(product: Product) -> OrderProduct {
        OrderProduct(id: self.id, product: product, quantity: self.quantity,
                     status: self.status, total: product.price * Double(quantity))
    }
}
