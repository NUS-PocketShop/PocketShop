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
    var couponId: String?
    var couponType: CouponType?
    var couponAmount: Double?

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
        self.couponId = order.couponId?.strVal
        self.couponType = order.couponType
        self.couponAmount = order.couponAmount
    }

    func toOrder() -> Order {
        var orderProducts = [OrderProduct]()

        if let orderProductSchemas = self.orderProductSchemas {
            for orderProductSchema in orderProductSchemas.values {
                let orderProduct = orderProductSchema.toOrderProduct()
                orderProducts.append(orderProduct)
            }
        }

        var couponId: ID?
        if let couponIdStr = self.couponId {
            couponId = ID(strVal: couponIdStr)
        }
        return Order(id: ID(strVal: self.id),
                     orderProducts: orderProducts,
                     status: self.status,
                     customerId: ID(strVal: self.customerId),
                     shopId: ID(strVal: self.shopId),
                     shopName: self.shopName,
                     date: self.date,
                     collectionNo: self.collectionNo,
                     couponId: couponId,
                     couponType: self.couponType,
                     couponAmount: self.couponAmount)
    }
}
