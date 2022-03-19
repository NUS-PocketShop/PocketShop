import Foundation
struct Order {
    var id: String
    var orderProducts: [OrderProduct]
    var status: OrderStatus
    var customerId: String
    var shopId: String
    var date: Date
}
