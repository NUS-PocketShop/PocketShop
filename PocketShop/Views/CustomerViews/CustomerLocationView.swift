import SwiftUI

struct CustomerLocationView: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var location: Location

    var body: some View {
        LocationHeader(name: location.name,
                       address: location.address,
                       postalCode: location.postalCode,
                       imageUrl: location.imageURL)
        Spacer()
        LocationShopsList(location: location)
    }
}

struct LocationHeader: View {
    var name: String
    var address: String
    var postalCode: Int
    var imageUrl: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.appTitle)
                    .padding(.bottom)

                Text(address)
                    .font(.appHeadline)
                    .padding(.bottom)

                Text("Postal Code: \(String(postalCode))")
                    .font(.appBody)
                    .padding(.bottom)
            }
            Spacer()
            URLImage(urlString: imageUrl)
                .scaledToFit()
                .frame(width: 100, height: 100)
        }.padding()
    }
}

struct LocationShopsList: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var location: Location

    var body: some View {
        if (!viewModel.locations.contains(where: { $0.name == location.name })) {
            Text("This location has no shops... yet!")
            Spacer()
        } else {
            Text("Shops")
                .font(.appTitle)
            List {
                ForEach(viewModel.shops, id: \.self) { shop in
                    if shop.locationId == location.id {
                        ShopPreview(shop: shop)
                    }
                }
            }
        }
    }
}

struct ShopPreview: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    @State var shop: Shop

    var body: some View {
        VStack {
            if shop.isClosed {
                ShopListView(shop: shop).environmentObject(viewModel)
                    .opacity(0.5)
            } else {
                NavigationLink(destination: CustomerShopView(shop: shop)) {
                    ShopListView(shop: shop).environmentObject(viewModel)
                }
            }
        }
    }
}

struct CustomerLocationView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLocation = CustomerViewModel().locations.first!
        CustomerLocationView(location: sampleLocation)
    }
}
