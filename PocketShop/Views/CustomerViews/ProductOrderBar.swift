import SwiftUI

struct ProductOrderBar: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @State var quantity: Int = 1
    var product: Product

    var body: some View {
        VStack {
            ProductOptionsGroup(options: product.options)
            HStack {
                QuantitySelector(quantity: $quantity)
                PriceAndOrderButton(customerViewModel: _customerViewModel,
                                    product: product,
                                    quantity: $quantity)
            }
        }
        .padding(.bottom)
    }
}

struct ProductOptionsGroup: View {

    @State var options: [ProductOption]

    var body: some View {
        if !options.isEmpty {
            VStack(alignment: .leading) {
                Text("Additional options").font(.appHeadline)
                ScrollView(.vertical) {
                    ForEach(options, id: \.self) { option in
                        PSRadioButtonGroup(title: option.title,
                                           options: option.optionChoices.map({ choice in
                                            "\(choice.description) (+$\(choice.cost))"
                                           }),
                                           callback: {o in
                                            print(o)
                                           })
                    }
                }
            }
        }
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

    @State var isShowingAddToCartAlert = false

    var body: some View {
        VStack {
            // Price and order button
            Text(String(format: "Price: $%.2f", product.price * Double(quantity)))
                .font(.appHeadline)
            PSButton(title: "Add to Cart") {
                addToCart()
                isShowingAddToCartAlert = true
            }
            .buttonStyle(FillButtonStyle())
        }
        .alert(isPresented: $isShowingAddToCartAlert) {
            Alert(title: Text("Added to cart"),
                  message: Text("\(product.name) has been added to Cart."))
        }
        .padding()
    }

    func addToCart() {
        customerViewModel.addProductToCart(product,
                                           quantity: quantity,
                                           choices: [])
    }
}
