import SwiftUI

class CustomerChoices: ObservableObject {
    @Published var choices = [ProductOptionChoice]()
}

struct ProductOrderBar: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel

    @State var quantity: Int = 1
//    @State var choices = [ProductOptionChoice]()
    @StateObject var choices = CustomerChoices()
    var product: Product

    var body: some View {
        VStack {
            ProductOptionsGroup(availableOptions: product.options,
                                selectedOptions: choices)
            HStack {
                QuantitySelector(quantity: $quantity)
                PriceAndOrderButton(customerViewModel: _customerViewModel,
                                    product: product,
                                    quantity: $quantity,
                                    selectedOptions: choices)
            }
        }
        .padding(.bottom)
    }
}

struct ProductOptionsGroup: View {

    @State var availableOptions: [ProductOption]
    @ObservedObject var selectedOptions: CustomerChoices
    @State private var selectedIndices: [Int]

    init(availableOptions: [ProductOption], selectedOptions: CustomerChoices) {
        self._availableOptions = State(initialValue: availableOptions)
        self.selectedOptions = selectedOptions
        self._selectedIndices = State(initialValue: Array(repeating: -1, count: availableOptions.count))
    }

    var body: some View {
        if !availableOptions.isEmpty {
            VStack(alignment: .leading) {
                Text("Additional options").font(.appHeadline)
                ScrollView(.vertical) {
                    ForEach(0..<availableOptions.count, id: \.self) { index in
                        PSRadioButtonGroup(title: availableOptions[index].title,
                                           options: availableOptions[index].optionChoices.map({ choice in
                                            "\(choice.description) (+$\(choice.cost))"
                                           }),
                                           callback: {selected in
                                            addToSelection(optionIndex: index, choiceIndex: selected)
                                           })
                    }
                }
            }
        }
    }

    func addToSelection(optionIndex: Int, choiceIndex: Int) {
        // replace the selectedIndices array
        selectedIndices[optionIndex] = choiceIndex

        // map over selectedIndices to build selectedOptions binding
        var tempChoices = [ProductOptionChoice]()
        for i in 0..<selectedIndices.count where selectedIndices[i] != -1 {
            let choiceIndex = selectedIndices[i]
            tempChoices.append(availableOptions[i].optionChoices[choiceIndex])
        }
        selectedOptions.choices = tempChoices
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
    @ObservedObject var selectedOptions: CustomerChoices
    var price: Double {
        calculatePrice()
    }

    @State var isShowingAddToCartAlert = false

    var body: some View {
        VStack {
            // Price and order button
            Text(String(format: "Price: $%.2f", price))
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

    private func calculatePrice() -> Double {
        let basic = product.price
        let choices = selectedOptions.choices.reduce(0) { $0 + $1.cost }
        return (basic + choices) * Double(quantity)
    }

    func addToCart() {
        customerViewModel.addProductToCart(product,
                                           quantity: quantity,
                                           choices: selectedOptions.choices)
    }
}
