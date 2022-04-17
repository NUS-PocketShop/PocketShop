struct Coupon: Hashable {
    var id: ID
    var description: String
    var couponType: CouponType
    var amount: Double
    var minimumOrder: Double
    var rewardPointCost: Int

    func apply(total: Double) -> Double {
        switch couponType {
        case .flat:
            return total - amount
        case .multiplicative:
            return total * amount
        }
    }

    func calculateSavedValue(total: Double) -> Double {
        switch couponType {
        case .flat:
            return amount
        case .multiplicative:
            return total * (1 - amount)
        }
    }
}

enum CouponType: Int, Codable {
    case flat = 1
    case multiplicative = 2
}

enum CouponValidationError: Error {
    case notEnoughRewardsPoint
    case notEnoughMinSpend
}
