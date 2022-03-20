import SwiftUI

struct ProductListView: View {
    var product: Product

    var body: some View {
        HStack {
            URLImage(urlString: product.imageURL)
                .scaledToFit()
                .frame(width: 100, height: 100) // Might change to relative sizes
                .padding(.leading)

            Text(product.name)
                .font(.appButton)
                .foregroundColor(Color.black)
                .padding(.leading)

            Spacer()

            VStack {
                Text(String(format: "$%.2f", product.price))
                    .font(.appButton)
                    .foregroundColor(Color.black)
                    .padding([.bottom, .trailing])

                Button(action: {
                    // Add product to order

                }, label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(Color.accent)
                        .padding(.trailing)
                })
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
