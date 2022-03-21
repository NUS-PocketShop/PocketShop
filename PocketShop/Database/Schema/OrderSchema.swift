import Foundation
struct OrderSchema: Codable {
    var id: String
    var orderProductSchemas: [String: OrderProductSchema]? = [:]
    var status: OrderStatus
    var customerId: String
    var shopId: String
    var date: Date
    var collectionNo: Int

    init(order: Order) {
        self.id = order.id
        self.orderProductSchemas = [:]
        self.status = order.status
        self.customerId = order.customerId
        self.shopId = order.shopId
        self.date = order.date
        self.collectionNo = order.collectionNo
        var counter = 0
        for orderProduct in order.orderProducts {
            self.orderProductSchemas?[String(counter)] = OrderProductSchema(orderProduct: orderProduct)
            counter += 1
        }
    }

    func toOrder(orderProducts: [OrderProduct], total: Double) -> Order {
        Order(id: self.id, orderProducts: orderProducts,
              status: self.status, customerId: self.customerId, shopId: self.shopId,
              date: self.date, collectionNo: self.collectionNo, total: total)
    }
}
