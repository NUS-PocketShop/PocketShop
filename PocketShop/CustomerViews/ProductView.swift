import SwiftUI

struct ProductView: View {
    var product: Product

    var body: some View {
        VStack {
            Text(product.name)
                .font(.title)
                .fontWeight(.bold)

            // Image from local assets (named by product id)
            Image(product.id)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200) // Might change to relative sizes

            Text(product.description)
                .padding(.bottom)

            Text(String(format: "$%.2f", product.price))
                .fontWeight(.semibold)

            // TODO: Add quantity and order buttons
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProduct = CustomerViewModel().products.first!
        ProductView(product: sampleProduct)
    }
}
