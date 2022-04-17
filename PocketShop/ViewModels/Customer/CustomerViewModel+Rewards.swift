/// Handles rewards/coupons systems

extension CustomerViewModel {
    func getValidCoupons(total: Double) -> [Coupon] {
        customerCoupons.filter { coupon in
            coupon.minimumOrder <= total
        }
    }

    func customerCouponCount(_ coupon: Coupon) -> Int {
        customer?.couponIds[coupon.id] ?? 0
    }

    func changeRewardPoints(points: Int) {
        self.customer?.rewardPoints += points
        guard let customer = customer else {
            return
        }
        DatabaseInterface.db.setRewardPoints(userId: customer.id,
                                             rewardPoints: customer.rewardPoints)
    }

    func buyCoupon(couponId: ID) throws {
        guard let coupon = coupons.first(where: { $0.id == couponId }),
              let customer = customer else {
            return
        }

        guard customer.rewardPoints >= coupon.rewardPointCost else {
            throw CouponValidationError.notEnoughRewardsPoint
        }

        changeRewardPoints(points: -coupon.rewardPointCost)
        changeCouponQuantity(coupon: coupon, quantity: 1)
    }

    func useCoupon(couponId: ID) {
        guard let coupon = coupons.first(where: { $0.id == couponId }) else {
            return
        }

        changeCouponQuantity(coupon: coupon, quantity: -1)
    }

    private func changeCouponQuantity(coupon: Coupon, quantity: Int) {
        guard let customer = self.customer else {
            return
        }
        var customerCoupons = customer.couponIds
        if let currentCouponCount = customerCoupons[coupon.id] {
            customerCoupons[coupon.id] = currentCouponCount + quantity
        } else {
            customerCoupons[coupon.id] = quantity
        }

        if quantity < 0 {
            customerCoupons[coupon.id] = 0
        }

        DatabaseInterface.db.setCoupons(userId: customer.id, coupons: customerCoupons)
    }

}
