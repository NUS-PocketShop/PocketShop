import SwiftUI

struct ShopsScrollView: View {
    @EnvironmentObject var viewModel: CustomerViewModel

    var body: some View {
        VStack {
            if !viewModel.shopSearchResults.isEmpty {
                Text("Shops")
                    .font(.appTitle)
                    .foregroundColor(.gray9)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.shopSearchResults, id: \.self) { shop in
                        NavigationLink(destination: CustomerShopView(shop: shop)
                                        .environmentObject(viewModel)) {
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
        ShopsScrollView().environmentObject(CustomerViewModel())
    }
}
