import SwiftUI

struct ShopSummaryView: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var shop: Shop

    var body: some View {
        VStack {
            URLImage(urlString: shop.imageURL)
                .scaledToFit()
                .frame(width: 150, height: 150)

            Text(viewModel.getLocationNameFromLocationId(locationId: shop.locationId))
                .font(.appSubheadline)
                .foregroundColor(.gray6)

            Text(shop.name)
                .font(.appHeadline)
                .foregroundColor(.gray9)
                .padding(.bottom)
        }
        .opacity(shop.isClosed ? 0.5 : 1)
        .padding()
    }
}

struct ShopSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleShop = CustomerViewModel().shops.first!
        ShopSummaryView(shop: sampleShop)
    }
}
