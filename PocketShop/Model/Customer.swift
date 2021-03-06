struct Customer: User, Codable {
    var id: ID
    var favouriteProductIds: [ID] = []
    var rewardPoints: Int = 0
    var couponIds: [ID: Int] = [:]
}
