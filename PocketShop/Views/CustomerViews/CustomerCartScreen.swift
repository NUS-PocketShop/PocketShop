import SwiftUI

struct CustomerCartScreen: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        NavigationView {
            VStack {
                CartList()
                Footer()
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
        .sheet(isPresented: $viewModel.showModal) {
            CouponListView(cartViewModel: viewModel)
        }
    }

    @ViewBuilder
    func CartList() -> some View {
        ScrollView(.vertical) {
            ForEach(viewModel.cartProducts, id: \.self) { cartProduct in
                CartItem(cartProduct: cartProduct)
            }
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

    @ViewBuilder
    func Footer() -> some View {
        HStack {
            ApplyCouponSection()
                .frame(height: 200)

            Spacer()

            OrderButtonSection()
                .frame(height: 200)
        }
    }

    @ViewBuilder
    func ApplyCouponSection() -> some View {
        VStack {
            Spacer()

            Text("\(viewModel.selectedCoupon?.description ?? "No coupon selected")")
                .font(.appHeadline)
                .bold()

            PSButton(title: "Apply Coupon") {
                viewModel.showCoupons()
            }
            .buttonStyle(FillButtonStyle())
            .frame(width: 150)
        }
        .frame(width: 200)
    }

    @ViewBuilder
    func OrderButtonSection() -> some View {
        VStack {
            Spacer()

            Text(String(format: "Total: $%.2f", viewModel.total))
                .font(.appHeadline)
                .bold()

            if viewModel.selectedCoupon != nil {
                Text(String(format: "Saved: $%.2f", viewModel.saved))
                    .font(.appHeadline)
                    .bold()
            }

            PSButton(title: "Order") {
                viewModel.confirmOrder()
            }
            .buttonStyle(FillButtonStyle())
        }
        .frame(width: 150)
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
                      message: Text("Remove \(cartProduct.productName) from cart?"),
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
        @Published var cartProducts: [CartProduct] = [] {
            didSet {
                selectedCoupon = nil
            }
        }
        @Published var showAlert = false
        @Published var showModal = false
        @Published var activeAlert: ActiveAlert = .showError
        @Published var errorMessage = ""
        @Published var selectedCoupon: Coupon?

        var cartProductsByShop: [ID: [CartProduct]] {
            Dictionary(grouping: cartProducts, by: { $0.shopId })
        }

        var getMaximumCostFromOneShop: Double {
            cartProductsByShop.reduce(0) { result, cartDict in
                max(result, getTotalPrice(cartProducts: cartDict.value))
            }
        }

        var customerCoupons: [Coupon] {
            customerViewModel.customerCoupons.sorted {
                selectedCoupon == $0 || selectedCoupon != $1 ||
                canApplyCoupon($0) || !canApplyCoupon($1)
            }
        }

        var totalBeforeDiscount: Double {
            cartProducts.reduce(0) { result, cartProduct in
                result + cartProduct.total
            }
        }

        private func getTotalPrice(cartProducts: [CartProduct]) -> Double {
            customerViewModel.getTotalPrice(cartProducts: cartProducts)
        }

        var saved: Double {
            selectedCoupon?.calculateSavedValue(total: getMaximumCostFromOneShop) ?? 0
        }

        var total: Double {
            totalBeforeDiscount - saved
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
            guard checkSelectedCoupon() else {
                return
            }

            let invalidCartProducts = customerViewModel.makeOrderFromCart(with: selectedCoupon)

            guard invalidCartProducts == nil else {
                let invalidCartProducts = invalidCartProducts!

                showError(cartProduct: invalidCartProducts[0].1, error: invalidCartProducts[0].0)
                return
            }
        }

        func customerCouponCount(_ coupon: Coupon) -> Int {
            customerViewModel.customerCouponCount(coupon)
        }

        func canApplyCoupon(_ coupon: Coupon) -> Bool {
            coupon.minimumOrder <= getMaximumCostFromOneShop
        }

        func applyCoupon(coupon: Coupon) {
            selectedCoupon = coupon
        }

        func deselectCoupon() {
            selectedCoupon = nil
        }

        private func checkSelectedCoupon() -> Bool {
            guard let selectedCoupon = selectedCoupon else {
                return true
            }

            if !canApplyCoupon(selectedCoupon) {
                activeAlert = .showError
                errorMessage = "You are trying to apply invalid coupon. Try again"
                self.selectedCoupon = nil
                showAlert.toggle()
                return false
            }

            return true
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

        func showCoupons() {
            showModal.toggle()
        }

        func removeCartProduct(_ cartProduct: CartProduct) {
            customerViewModel.removeCartProduct(cartProduct)
        }
    }
}

struct CustomerCartScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerCartScreen(viewModel: .init(customerViewModel: .init()))
    }
}
