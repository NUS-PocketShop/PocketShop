struct CouponSchema: Hashable, Codable {
    var id: String
    var description: String
    var couponType: CouponType
    var amount: Double
    var minimumOrder: Double
    var rewardPointCost: Int

    init(coupon: Coupon) {
        self.id = coupon.id.strVal
        self.description = coupon.description
        self.couponType = coupon.couponType
        self.amount = coupon.amount
        self.minimumOrder = coupon.minimumOrder
        self.rewardPointCost = coupon.rewardPointCost
    }

    func toCoupon() -> Coupon {
        Coupon(id: ID(strVal: id),
               description: self.description,
               couponType: self.couponType,
               amount: self.amount,
               minimumOrder: self.minimumOrder,
               rewardPointCost: self.rewardPointCost)
    }
}
