import SwiftUI

struct ShopProductListView: View {
    var product: Product

    var body: some View {
        HStack {
            ProductListView(product: product)
            Spacer()
            ToggleProductStockStatusButton(product: product)
        }
    }
}

struct ToggleProductStockStatusButton: View {
    @EnvironmentObject var viewModel: VendorViewModel
    var product: Product

    var body: some View {
        Text(product.isOutOfStock
             ? "In Stock \(Image(systemName: "checkmark"))"
             : "Out of Stock \(Image(systemName: "nosign"))")
            .foregroundColor(Color.accent)
            .font(.appCaption)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 4.0)
                    .stroke(Color.accent, lineWidth: 1)
            )
            .onTapGesture {
                viewModel.toggleProductStockStatus(product: product)
            }
    }
}
