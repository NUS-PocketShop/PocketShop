enum OrderStatus: Int, Codable {
    case pending = 1
    case accepted = 2
    case preparing = 3
    case ready = 4
    case collected = 5
    
    func toString() -> String {
        switch self {
        case .pending:
            return "PENDING"
        case .accepted:
            return "ACCEPTED"
        case .preparing:
            return "PREPARING"
        case .ready:
            return "READY"
        case .collected:
            return "COLLECTED"
        }
    }
}
