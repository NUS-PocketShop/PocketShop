import Foundation
struct OrderSchema: Codable {
    var id: String
    var orderProductSchemas: [String: OrderProductSchema]? = [:]
    var status: OrderStatus
    var customerId: String
    var shopId: String
    var shopName: String
    var date: Date
    var collectionNo: Int

    init(order: Order) {
        self.id = order.id.strVal
        self.orderProductSchemas = [:]
        self.status = order.status
        self.customerId = order.customerId.strVal
        self.shopId = order.shopId.strVal
        self.shopName = order.shopName
        self.date = order.date
        self.collectionNo = order.collectionNo
        var counter = 0
        for orderProduct in order.orderProducts {
            self.orderProductSchemas?[String(counter)] = OrderProductSchema(orderProduct: orderProduct)
            counter += 1
        }
    }

    func toOrder() -> Order {
        var orderProducts = [OrderProduct]()
        var total = 0.0
        if let orderProductSchemas = self.orderProductSchemas {
            for orderProductSchema in orderProductSchemas.values {
                let orderProduct = orderProductSchema.toOrderProduct()
                orderProducts.append(orderProduct)
                total += orderProduct.total
            }
        }
        return Order(id: ID(strVal: self.id),
                     orderProducts: orderProducts,
                     status: self.status,
                     customerId: ID(strVal: self.customerId),
                     shopId: ID(strVal: self.shopId),
                     shopName: self.shopName,
                     date: self.date,
                     collectionNo: self.collectionNo,
                     total: total)
    }
}
