import SwiftUI

struct ProductListView: View {
    var product: Product

    var body: some View {
        HStack {
            URLImage(urlString: product.imageURL)
                .scaledToFit()
                .frame(width: 100, height: 100) // Might change to relative sizes
                .padding([.top, .leading, .bottom])

            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.appButton)
                    .foregroundColor(Color.black)
                    .padding([.leading, .bottom])

                Text(String(format: "$%.2f", product.price))
                    .font(.appButton)
                    .foregroundColor(Color.black)
                    .padding(.leading)
            }
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProduct = CustomerViewModel().products.first!
        ProductListView(product: sampleProduct)
    }
}
