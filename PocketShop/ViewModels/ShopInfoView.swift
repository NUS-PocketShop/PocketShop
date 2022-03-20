import SwiftUI

struct ShopInfoView: View {
    var shop: Shop

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack {
                    Text(shop.description)
                        .font(.appHeadline)
                        .padding(.bottom)
                }
                Spacer()
                URLImage(urlString: shop.imageURL)
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Might change to relative sizes
            }.padding()

            Text("Products")
                .font(.appTitle)

            if shop.soldProducts.isEmpty {
                Text("Your shop has no products... yet!")
            } else {
                List {
                    ForEach(shop.soldProducts, id: \.self) { product in
                        ProductListView(product: product)
                    }
                }
            }
        }.padding()
    }

}
