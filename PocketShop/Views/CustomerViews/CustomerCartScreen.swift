import SwiftUI

struct CustomerCartScreen: View {
    @ObservedObject private(set) var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            Text("Cart Screen")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    func cartItem() -> some View {
        
    }
}

extension CustomerCartScreen {
    class ViewModel: ObservableObject {
        @ObservedObject private var customerViewModel: CustomerViewModel
        @Published var cartProducts: [CartProduct] = []
        @Published var showError = false
        @Published var errorMessage = ""
        
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
                errorMessage = "\(cartProduct.productName) has been changed by the vendor. Please re-order"
            case .productDeleted:
                errorMessage = "\(cartProduct.productName) has been deleted by the vendor."
            case .productOutOfStock:
                errorMessage = "\(cartProduct.productName) is out of stock."
            case .shopClosed:
                errorMessage = "Shop that sells \(cartProduct.productName) is closed :("
            }
            showError = true
        }
    }
}

struct CustomerCartScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomerCartScreen(viewModel: .init(customerViewModel: CustomerViewModel()))
    }
}
