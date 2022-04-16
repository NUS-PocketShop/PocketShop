struct CustomerSchema: Codable {
    var id: String
    var favouriteProductIds: [String]? = []
    var rewardPoints: Int = 0

    init(customer: Customer) {
        self.id = customer.id.strVal
        self.favouriteProductIds = customer.favouriteProductIds.map({ $0.strVal })
        self.rewardPoints = customer.rewardPoints
    }

    func toCustomer() -> Customer {
        Customer(id: ID(strVal: self.id),
                 favouriteProductIds: (self.favouriteProductIds ?? []).map({ ID(strVal: $0) }),
                 rewardPoints: self.rewardPoints)
    }
}
