struct OrderSchema: Codable {
    var id: String
    var orderProductSchemas: [OrderProductSchema]
    var status: OrderStatus
    var customerId: String
    var shopId: String

    init(order: Order) {
        self.id = order.id
        self.orderProductSchemas = []
        self.status = order.status
        self.customerId = order.customerId
        self.shopId = order.shopId
        for orderProduct in order.orderProducts {
            self.orderProductSchemas.append(OrderProductSchema(orderProduct: orderProduct))
        }
    }

    func toOrder(orderProducts: [OrderProduct]) -> Order {
        Order(id: self.id, orderProducts: orderProducts,
              status: self.status, customerId: self.customerId, shopId: self.shopId)
    }
}
