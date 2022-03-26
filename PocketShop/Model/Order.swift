import SwiftUI

struct Order: Hashable, Identifiable {
    var id: String
    var orderProducts: [OrderProduct]
    var status: OrderStatus
    var customerId: String
    var shopId: String
    var shopName: String
    var date: Date
    var collectionNo: Int
    var total: Double

    var isHistory: Bool {
        status == .collected
    }

    var ringColor: Color {
        switch status {
        case .pending, .accepted, .preparing:
            return .gray6
        case .ready, .collected:
            return .success
        }
    }

    private let dateFormatter = DateFormatter()
    var orderDateString: String {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    var orderTimeString: String {
        dateFormatter.dateFormat = "HH:mm a"
        return dateFormatter.string(from: date)
    }
}
