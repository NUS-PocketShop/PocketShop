struct CustomerSchema: Codable {
    var id: String
    var favouriteProductIds: [String]? = []
    var rewardPoints: Int = 0

    init(customer: Customer) {
        self.id = customer.id
        self.favouriteProductIds = customer.favouriteProductIds
        self.rewardPoints = customer.rewardPoints
    }

    func toCustomer() -> Customer {
        Customer(id: self.id,
                 favouriteProductIds: self.favouriteProductIds ?? [],
                 rewardPoints: self.rewardPoints)
    }
}
