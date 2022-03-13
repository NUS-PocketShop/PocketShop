import SwiftUI

struct ProductSummaryView: View {
    var product: Product

    var body: some View {
        VStack {
            // Image from local assets (named by product id)
            Image(product.id)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150) // Might change to relative sizes

            Text(product.shopName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.gray)

            Text(product.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
                .padding(.bottom)

            Text(String(format: "$%.2f", product.price))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
        }
        .padding()
    }
}

struct ProductSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProduct = CustomerViewModel().products.first!
        ProductSummaryView(product: sampleProduct)
    }
}
