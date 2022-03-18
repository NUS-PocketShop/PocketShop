import SwiftUI

struct ShopsScrollView: View {
    @StateObject var viewModel: CustomerViewModel

    var body: some View {
        VStack {
            Text("Shops")
                .font(.appTitle)
                .foregroundColor(.gray9)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.shopSearchResults, id: \.self) { shop in
                        NavigationLink(destination: CustomerShopView(viewModel: viewModel, shop: shop)) {
                            ShopSummaryView(shop: shop)
                        }
                    }
                }
            }
        }
    }
}

struct ShopsScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ShopsScrollView(viewModel: CustomerViewModel())
    }
}
