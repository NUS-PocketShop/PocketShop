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
    
    var totalBeforeDiscount: Double {
        orderProducts.reduce(0) { $0 + $1.total }
    }
    
    var total: Double {
        var total = totalBeforeDiscount
        
        if self.couponType == .flat, let couponAmount = self.couponAmount {
            total -= couponAmount
        } else if self.couponType == .multiplicative, let couponAmount = self.couponAmount {
            total *= couponAmount
        }
        
        return total
    }
}
