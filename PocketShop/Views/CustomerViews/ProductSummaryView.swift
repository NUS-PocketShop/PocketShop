import SwiftUI

struct ProductSummaryView: View {
    var product: Product

    var body: some View {
        VStack {
            URLImage(urlString: product.imageURL)
                .scaledToFit()
                .frame(width: 150, height: 150) // Might change to relative sizes

            Text(product.shopName)
                .font(.appSubheadline)
                .foregroundColor(.gray6)

            Text(product.name)
                .font(.appHeadline)
                .foregroundColor(.gray9)
                .padding(.bottom)

            Text(String(format: "$%.2f", product.price))
                .font(.appBody)
                .foregroundColor(.accent)
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
