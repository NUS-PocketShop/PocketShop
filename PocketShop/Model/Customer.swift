struct Customer: User, Codable {
    var id: String
    var favouriteProductIds: [String] = []
    var rewardPoints: Int = 0
}
