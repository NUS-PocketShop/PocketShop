struct CustomerSchema: Codable {
    var id: String
    var favouriteProductIds: [String]? = []
    var rewardPoints: Int = 0
    var couponIds: [String: Int]? = [:]

    init(customer: Customer) {
        self.id = customer.id.strVal
        self.favouriteProductIds = customer.favouriteProductIds.map({ $0.strVal })
        self.rewardPoints = customer.rewardPoints
        self.couponIds = [:]
        for key in customer.couponIds.keys {
            self.couponIds?[key.strVal] = customer.couponIds[key]
        }
    }

    func toCustomer() -> Customer {
        var couponIds: [ID: Int] = [:]
        if let couponStrIds = self.couponIds {
            for key in couponStrIds.keys {
                couponIds[ID(strVal: key)] = couponStrIds[key]
            }
        }
        return Customer(id: ID(strVal: self.id),
                        favouriteProductIds: (self.favouriteProductIds ?? []).map({ ID(strVal: $0) }),
                        rewardPoints: self.rewardPoints,
                        couponIds: couponIds)
    }
}
