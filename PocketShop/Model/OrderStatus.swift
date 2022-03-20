enum OrderStatus: Int, Codable {
    case pending = 1
    case accepted = 2
    case preparing = 3
    case ready = 4
    case collected = 5
}
