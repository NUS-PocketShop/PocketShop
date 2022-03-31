import SwiftUI

struct Order: Hashable, Identifiable {
    var id: String
    var orderProducts: [OrderProduct]
    var status: OrderStatus
    var customerId: String
    var shopId: String
    var shopName: String
    var date: Date
    var collectionNo: Int
    var total: Double
}
