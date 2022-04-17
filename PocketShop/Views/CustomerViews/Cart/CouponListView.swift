import SwiftUI

struct CouponListView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var cartViewModel: CustomerCartScreen.ViewModel

    var body: some View {
        NavigationView {
            Group {
                if cartViewModel.customerCoupons.isEmpty {
                    Text("You don't have any coupons right now")
                        .font(.title)
                } else {
                    ScrollView(.vertical) {
                        VStack(alignment: .leading) {
                            ForEach(cartViewModel.customerCoupons, id: \.self) { coupon in
                                couponItem(coupon: coupon, quantity: cartViewModel.customerCouponCount(coupon))
                                    .opacity(cartViewModel.canApplyCoupon(coupon) ? 1.0 : 0.5)
                                Divider()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .navigationTitle("Your Coupons")
        }
    }

    @ViewBuilder
    func couponItem(coupon: Coupon, quantity: Int) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(coupon.description)")
                    .font(.appHeadline)

                DiscountTextView(coupon: coupon)

                Text("Minimum order: $\(String(format: "%.2f", coupon.minimumOrder))")

                Text("Coupons left: \(quantity)")
                    .font(.subheadline)
                    .padding(.top)
            }

            Spacer()

            PSButton(title: cartViewModel.selectedCoupon == coupon ? "Remove Coupon" : "Apply Coupon") {
                if cartViewModel.selectedCoupon == coupon {
                    cartViewModel.deselectCoupon()
                    presentationMode.wrappedValue.dismiss()
                } else if cartViewModel.canApplyCoupon(coupon) {
                    cartViewModel.applyCoupon(coupon: coupon)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .padding()
    }
}

struct CouponListView_Previews: PreviewProvider {
    static var previews: some View {
        CouponListView(cartViewModel: .init(customerViewModel: .init()))
    }
}
