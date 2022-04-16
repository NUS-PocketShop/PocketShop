struct Coupon: Hashable {
    var id: ID
    var description: String
    var couponType: CouponType
    var amount: Double
    var minimumOrder: Double
    var rewardPointCost: Int
}

enum CouponType: Int, Codable {
    case flat = 1
    case multiplicative = 2
}
