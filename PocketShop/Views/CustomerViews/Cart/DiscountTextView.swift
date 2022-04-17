import SwiftUI

struct DiscountTextView: View {
    var coupon: Coupon

    var body: some View {
        switch coupon.couponType {
        case .flat:
            return Text("$\(String(format: "%.2f", coupon.amount)) off")
        case .multiplicative:
            return Text("\(String(format: "%.0f", (1 - coupon.amount) * 100))% off")
        }
    }
}
