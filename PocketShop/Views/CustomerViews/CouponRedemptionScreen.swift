import SwiftUI

struct CouponRedemptionScreen: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @State var showAlert = false
    @State var activeAlert: ActiveAlert = .success

    var body: some View {
        VStack {
            Text("You have \(customerViewModel.customer?.rewardPoints ?? 0) rewards point(s)")
                .font(.appHeadline)
                .padding()
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    ForEach(customerViewModel.coupons, id: \.self) { coupon in
                        CouponItem(coupon: coupon,
                                   quantity: customerViewModel.customerCouponCount(coupon))
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .navigationTitle("Coupon Redemption")
        }
        
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .success:
                return redeemSuccessAlert()
            case .fail:
                return insufficientPointsAlert()
            }
        }
    }
    
    @ViewBuilder
    func CouponItem(coupon: Coupon, quantity: Int) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(coupon.description)")
                    .font(.appHeadline)
                
                getDiscountText(coupon: coupon)
                
                Text("Minimum order: $\(String(format: "%.2f", coupon.minimumOrder))")
                    .font(.appBody)
                
                Text("Rewards Points Needed: \(coupon.rewardPointCost)")
                    .font(.appBody)
                
                Text("Coupons left: \(quantity)")
                    .font(.subheadline)
                    .padding(.top)
            }

            Spacer()

            PSButton(title: "Redeem Coupon") {
                do {
                    try customerViewModel.buyCoupon(couponId: coupon.id)
                    activeAlert = .success
                } catch CouponValidationError.notEnoughRewardsPoint {
                    activeAlert = .fail
                } catch {
                    fatalError("Unknown error occurred")
                }
                showAlert.toggle()
            }
        }
        .padding()
    }
    
    func getDiscountText(coupon: Coupon) -> Text {
        switch coupon.couponType {
        case .flat:
            return Text("$\(String(format: "%.2f", coupon.amount)) off")
        case .multiplicative:
            return Text("\(String(format: "%.0f", (1 - coupon.amount) * 100))% off")
        }
    }
    
    private func redeemSuccessAlert() -> Alert {
        Alert(title: Text("Coupon Redeemed"),
              message: Text("Coupon Redeemed Successfully"),
              dismissButton: .default(Text("OK")))
    }
    
    private func insufficientPointsAlert() -> Alert {
        Alert(title: Text("Cannot Redeem Coupon"),
              message: Text("You do not have enough rewards point to redeem the selected coupon"),
              dismissButton: .default(Text("OK")))
    }
}

extension CouponRedemptionScreen {
    enum ActiveAlert {
        case success, fail
    }
}

struct CouponRedemptionView_Previews: PreviewProvider {
    static var previews: some View {
        CouponRedemptionScreen()
    }
}
