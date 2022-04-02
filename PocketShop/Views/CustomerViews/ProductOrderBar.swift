import SwiftUI

struct ProductOrderBar: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @State var quantity: Int = 1
    var product: Product

    var body: some View {
        HStack {
            QuantitySelector(quantity: $quantity)
            PriceAndOrderButton(customerViewModel: _customerViewModel,
                                product: product,
                                quantity: $quantity)
        }
        .padding(.bottom)
    }
}

struct QuantitySelector: View {
    @Binding var quantity: Int

    var body: some View {
        VStack {
            Text("Quantity")
                .font(.appHeadline)
            HStack {
                PSButton(title: "-") {
                    if quantity > 1 { quantity -= 1 }
                }
                .buttonStyle(OutlineButtonStyle())
                Text(String(quantity))
                    .font(.appButton)
                    .padding(.horizontal)
                PSButton(title: "+") {
                    if quantity < 1_000 { quantity += 1 }
                }
                .buttonStyle(OutlineButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}

struct PriceAndOrderButton: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    var product: Product
    @Binding var quantity: Int

    var body: some View {
        VStack {
            // Price and order button
            Text(String(format: "Price: $%.2f", product.price * Double(quantity)))
                .font(.appHeadline)
            PSButton(title: "ORDER") {
                customerViewModel.addProductToCart(product, quantity: quantity, choices: product.optionChoices)
            }
            .buttonStyle(FillButtonStyle())
        }
        .padding()
    }
}
