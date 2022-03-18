import SwiftUI

struct ShopSummaryView: View {
    var shop: Shop

    var body: some View {
        VStack {
            // Image from local assets (named by product id)
            Image(shop.id)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150) // Might change to relative sizes

            Text(shop.description)
                .font(.appSubheadline)
                .foregroundColor(.gray6)

            Text(shop.name)
                .font(.appHeadline)
                .foregroundColor(.gray9)
                .padding(.bottom)

        }
        .padding()
    }
}

struct ShopSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleShop = CustomerViewModel().shops.first!
        ShopSummaryView(shop: sampleShop)
    }
}
