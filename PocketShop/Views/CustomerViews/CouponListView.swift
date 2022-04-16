//
//  CouponListView.swift
//  PocketShop
//
//  Created by Dasco Gabriel on 16/4/22.
//

import SwiftUI

struct CouponListView: View {
    @State var randomTexts = ["1", "3", "2"]

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                ForEach(randomTexts, id: \.self) { randomText in
                    couponItem(coupon: randomText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    @ViewBuilder
    func couponItem(coupon: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Coupon Name")
                    .font(.appHeadline)

                Text("Discount 10%")
                    .font(.appBody)

                Text("Minimum Spend: $11")
                    .font(.appBody)
            }

            Spacer()

            PSButton(title: "Apply Coupon") {

            }
        }
        .padding()
    }
}

struct CouponListView_Previews: PreviewProvider {
    static var previews: some View {
        CouponListView()
    }
}
