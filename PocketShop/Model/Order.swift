import Foundation

struct Order: Hashable, Identifiable {
    var id: ID
    var orderProducts: [OrderProduct]
    var status: OrderStatus
    var customerId: ID
    var shopId: ID
    var shopName: String
    var date: Date
    var collectionNo: Int
    var couponId: ID?
    var couponType: CouponType?
    var couponAmount: Double?
    var total: Double
}
