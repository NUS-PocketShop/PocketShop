import SwiftUI

class CustomerChoices: ObservableObject {
    @Published var choices = [ProductOptionChoice]()
    
    init() {}
    
    init(choices: [ProductOptionChoice]) {
        self.choices = choices
    }
}

struct ProductOrderBar: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel

    @State var quantity: Int = 1
    @ObservedObject var choices = CustomerChoices()
    var product: Product
    var cartProduct: CartProduct?
    
    init(product: Product) {
        self.product = product
    }
    
    init(product: Product, cartProduct: CartProduct?) {
        self.product = product
        self.cartProduct = cartProduct
        
        // If it has cartProduct, then we "edit cart" instead of "add to cart"
        if let cartProduct = cartProduct {
            self._quantity = State(initialValue: cartProduct.quantity)
            self.choices = CustomerChoices(choices: cartProduct.productOptionChoices)
        }
    }

    var body: some View {
        VStack {
            ProductOptionsGroup(availableOptions: product.options,
                                selectedOptions: choices)
            Spacer()
            HStack {
                QuantitySelector(quantity: $quantity)
                PriceAndOrderButton(customerViewModel: _customerViewModel,
                                    product: product,
                                    cartProduct: cartProduct,
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

        // Initializes the chosen index if there is selectedOptions
        var tempIndices = Array(repeating: -1, count: availableOptions.count)

        for i in 0..<availableOptions.count {
            let availableOption = availableOptions[i]
            
            for j in 0..<availableOption.optionChoices.count {
                let optionChoice = availableOption.optionChoices[j]
                
                if selectedOptions.choices.contains(optionChoice) {
                    tempIndices[i] = j
                }
            }
        }


        self._selectedIndices = State(initialValue: tempIndices)
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
                                           selectedId: selectedIndices[index],
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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var customerViewModel: CustomerViewModel
    var product: Product
    var cartProduct: CartProduct?
    @Binding var quantity: Int
    @ObservedObject var selectedOptions: CustomerChoices
    var price: Double {
        calculatePrice()
    }

    @State var isShowingAlert = false

    var body: some View {
        VStack {
            // Price and order button
            Text(String(format: "Price: $%.2f", price))
                .font(.appHeadline)
            
            if cartProduct == nil {
                PSButton(title: "Add to Cart") {
                    addToCart()
                    isShowingAlert = true
                }
                .buttonStyle(FillButtonStyle())
            } else {
                PSButton(title: "Edit Cart Product") {
                    editCartProduct()
                    isShowingAlert = true
                }
                .buttonStyle(FillButtonStyle())
            }
        }
        .alert(isPresented: $isShowingAlert) {
            getAlert()
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
    
    func editCartProduct() {
        guard let cartProduct = cartProduct else {
            return
        }

        customerViewModel.editCartProduct(cartProduct,
                                          product: product,
                                          quantity: quantity,
                                          choices: selectedOptions.choices)
    }
    
    private func getAlert() -> Alert {
        if cartProduct == nil {
            return getAddToCartAlert()
        } else {
            return getEditCartProductAlert()
        }
    }
    
    private func getAddToCartAlert() -> Alert {
        Alert(title: Text("Added to cart"),
              message: Text("\(product.name) has been added to Cart."),
              dismissButton: .default(Text("Ok")) {
                presentationMode.wrappedValue.dismiss()
              })
    }
    
    private func getEditCartProductAlert() -> Alert {
        Alert(title: Text("Edited cart product"),
              message: Text("\(product.name) has been edited in your Cart."),
              dismissButton: .default(Text("Ok")) {
                presentationMode.wrappedValue.dismiss()
              })
    }
}
