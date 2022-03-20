import SwiftUI

struct ProductOrderBar: View {
    @State var quantity: Int = 1
    var product: Product

    var body: some View {
        HStack {
            VStack {
                // Quantity
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

            VStack {
                // Price and order button
                Text(String(format: "Price: $%.2f", product.price * Double(quantity)))
                    .font(.appHeadline)
                PSButton(title: "ORDER") {
                    // TODO: Order item

                }
                .buttonStyle(FillButtonStyle())
            }
            .padding()
        }
        .padding(.bottom)
    }
}
