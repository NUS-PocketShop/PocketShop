import SwiftUI

struct CustomerCartScreen: View {
    @ObservedObject private(set) var viewModel: ViewModel

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
                            viewModel.confirmOrder()
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
        .alert(isPresented: $viewModel.showAlert) {
            switch viewModel.activeAlert {
            case .showEmptyCart:
                return emptyCartAlert()
            case .showConfirmOrder:
                return makeOrderAlert()
            case .showError:
                return errorAlert()
            }
        }
    }

    private func emptyCartAlert() -> Alert {
        Alert(title: Text("Unable to Order"),
              message: Text("Unable to make order since your cart is empty"),
              dismissButton: .default(Text("OK")))
    }

    private func makeOrderAlert() -> Alert {
        Alert(title: Text("Confirm Order"),
              message: Text("Confirm to order items in cart?"),
              primaryButton: .default(Text("Confirm")) { viewModel.makeOrder() },
              secondaryButton: .destructive(Text("Cancel")))
    }

    private func errorAlert() -> Alert {
        Alert(title: Text("Oops"),
              message: Text("\(viewModel.errorMessage)"),
              dismissButton: .default(Text("OK")))
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

                CartItemDescription(cartProduct: cartProduct)

                Spacer()

                TrashAndEditCartItemButton(cartProduct: cartProduct)
            }
        }
        .padding()
    }
}

struct CartItemDescription: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var cartProduct: CartProduct

    var body: some View {
        VStack(alignment: .leading) {
            Text("""
                 \(cartProduct.shopName) (\(viewModel.getLocationNameFromShopId(shopId: cartProduct.shopId)))
                 """)
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
    }
}

struct TrashAndEditCartItemButton: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var cartProduct: CartProduct
    @State private var showConfirmDelete = false
    @State private var navigateToProductDetail = false

    var body: some View {
        NavigationLink(destination:
                        ProductDetailView(product: viewModel.getProductFor(cartProduct: cartProduct),
                                          cartProduct: cartProduct),
                        isActive: $navigateToProductDetail) {
            PSButton(title: "Edit") {
                navigateToProductDetail.toggle()
            }
        }
        .frame(width: 100)

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

extension CustomerCartScreen {
    enum ActiveAlert {
        case showError, showEmptyCart, showConfirmOrder
    }

    class ViewModel: ObservableObject {
        @ObservedObject var customerViewModel: CustomerViewModel
        @Published var cartProducts: [CartProduct] = []
        @Published var showAlert = false
        @Published var activeAlert: ActiveAlert = .showError
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

        func confirmOrder() {
            if cartProducts.isEmpty {
                activeAlert = .showEmptyCart
            } else {
                activeAlert = .showConfirmOrder
            }

            showAlert.toggle()
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

            activeAlert = .showError
            showAlert.toggle()
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
