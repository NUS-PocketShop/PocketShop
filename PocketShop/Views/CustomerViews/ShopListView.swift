import SwiftUI

struct ShopListView: View {
    var shop: Shop

    var body: some View {
        HStack {
            URLImage(urlString: shop.imageURL)
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding([.top, .leading, .bottom])

            VStack(alignment: .leading) {
                Text(shop.name)
                    .font(.appHeadline)
                    .foregroundColor(Color.black)
                    .padding([.leading, .bottom])

                Text(shop.description)
                    .font(.appCaption)
                    .foregroundColor(Color.black)
                    .padding(.leading)
            }
        }
    }
}

struct ShopListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CustomerViewModel()
        let sampleShop = viewModel.shops.first!
        ShopListView(shop: sampleShop).environmentObject(viewModel)
    }
}
