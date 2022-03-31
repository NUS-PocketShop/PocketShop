import Foundation
import SwiftUI

struct OrderViewModel {
    private let model: Order
    
    var id: String {
        model.id
    }
    
    var orderProducts: [OrderProduct] {
        model.orderProducts
    }
    
    var status: OrderStatus {
        model.status
    }
    
    var shopName: String {
        model.shopName
    }
    
    var collectionNo: Int {
        model.collectionNo
    }
    
    var total: Double {
        model.total
    }
    
    init(order: Order) {
        self.model = order
    }
    
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
    
    var showCancel: Bool {
        return status == .pending
    }

    private let dateFormatter = DateFormatter()
    var orderDateString: String {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: model.date)
    }
    var orderTimeString: String {
        dateFormatter.dateFormat = "HH:mm a"
        return dateFormatter.string(from: model.date)
    }
}

extension OrderViewModel: Hashable {
    static func == (lhs: OrderViewModel, rhs: OrderViewModel) -> Bool {
        lhs.model == rhs.model
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
