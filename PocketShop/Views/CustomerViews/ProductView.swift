import SwiftUI

struct ProductView: View {
    var product: Product

    var body: some View {
        VStack {
            Text(product.name)
                .font(.appTitle)

            URLImage(urlString: product.imageURL)
                .scaledToFit()
                .frame(width: 150, height: 150) // Might change to relative sizes

            Text(product.description)
                .padding(.vertical)
                .font(.appBody)

            Text(String(format: "$%.2f", product.price))
                .font(.appBody)
                .fontWeight(.semibold)

            ProductOrderBar(product: product)
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProduct = CustomerViewModel().products.first!
        ProductView(product: sampleProduct).environmentObject(CustomerViewModel())
    }
}
