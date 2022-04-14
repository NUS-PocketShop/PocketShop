import SwiftUI

struct ProductView: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var product: Product

    var body: some View {
        VStack {
            Text(product.name)
                .font(.appTitle)

            Text(product.shopName)
                .font(.appHeadline)
                .foregroundColor(.gray6)

            Text("(\(viewModel.getLocationNameFromProduct(product: product)))")
                .font(.appHeadline)
                .foregroundColor(.gray6)

            URLImage(urlString: product.imageURL)
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.vertical)

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
