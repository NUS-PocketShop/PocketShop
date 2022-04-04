import SwiftUI

struct CustomerCartScreen: View {
    @ObservedObject private(set) var viewModel: ViewModel
    @State private var showConfirmDelete = false

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical) {
                    CartList()
                }

                HStack {
                    Spacer()

                    VStack {
                        Text(String(format: "Total: %.2f", viewModel.total))
                            .font(.appHeadline)
                            .bold()

                        PSButton(title: "Order") {
                            viewModel.makeOrder()
                        }
                        .buttonStyle(FillButtonStyle())
                    }
                    .frame(width: 150)
                }
            }
            .navigationTitle("My Cart")
            .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Oops"),
                  message: Text("\(viewModel.errorMessage)"),
                  dismissButton: .default(Text("OK")))
        }
    }

    @ViewBuilder
    func CartList() -> some View {
        ForEach(viewModel.cartProducts, id: \.self) { cartProduct in
            CartItem(cartProduct: cartProduct)
        }
    }

    @ViewBuilder
    func CartItem(cartProduct: CartProduct) -> some View {
        VStack(alignment: .leading) {
            Text("\(cartProduct.productName)")
                .font(.appHeadline)
                .bold()

            HStack {
                URLImage(urlString: cartProduct.productImageURL)
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                VStack(alignment: .leading) {
                    Text("\(cartProduct.shopName)")
                        .font(.appBody)

                    Text("Qty: \(cartProduct.quantity)")
                        .font(.appBody)
                        .padding(.bottom)

                    if !cartProduct.productOptionChoices.isEmpty {
                        ForEach(cartProduct.productOptionChoices, id: \.self) { choice in
                            Text("\(choice.description) (+$\(choice.cost, specifier: "%.2f"))")
                                .font(.appBody)
                        }
                    }

                    Text(String(format: "$%.2f", cartProduct.total))
                        .font(.appBody)
                }

                Spacer()

                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.red)
                    .padding(.trailing)
                    .onTapGesture {
                        self.showConfirmDelete.toggle()
                    }
                    .alert(isPresented: $showConfirmDelete) {
                        Alert(title: Text("Confirmation"),
                              message: Text("Confirm to remove \(cartProduct.productName) from cart?"),
                              primaryButton: .destructive(Text("Yes")) {
                                    viewModel.removeCartProduct(cartProduct)
                              },
                              secondaryButton: .default(Text("No")))
                    }
            }
        }
        .padding()
    }
}

extension CustomerCartScreen {
    class ViewModel: ObservableObject {
        @ObservedObject private var customerViewModel: CustomerViewModel
        @Published var cartProducts: [CartProduct] = []
        @Published var showError = false
        @Published var errorMessage = ""

        var total: Double {
            cartProducts.reduce(0) { result, cartProduct in
                result + cartProduct.total
            }
        }

        init(customerViewModel: CustomerViewModel) {
            self.customerViewModel = customerViewModel
            self.cartProducts = customerViewModel.cart
        }

        func makeOrder() {
            let invalidCartProducts = customerViewModel.makeOrderFromCart()

            guard invalidCartProducts == nil else {
                let invalidCartProducts = invalidCartProducts!

                showError(cartProduct: invalidCartProducts[0].1, error: invalidCartProducts[0].0)
                return
            }
        }

        func showError(cartProduct: CartProduct, error: CartValidationError) {
            switch error {
            case .productChanged:
                errorMessage = "\(cartProduct.productName) has been changed by the vendor. Please re-order."
                removeCartProduct(cartProduct)
            case .productDeleted:
                errorMessage = "\(cartProduct.productName) has been deleted by the vendor."
            case .productOutOfStock:
                errorMessage = "\(cartProduct.productName) is out of stock."
            case .shopClosed:
                errorMessage = "Unable to order \(cartProduct.productName) since \(cartProduct.shopName) is closed :("
            }
            showError = true
        }

        func removeCartProduct(_ cartProduct: CartProduct) {
            customerViewModel.removeCartProduct(cartProduct)
        }
    }
}

struct CustomerCartScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerCartScreen(viewModel: .init(customerViewModel: CustomerViewModel()))
    }
}
