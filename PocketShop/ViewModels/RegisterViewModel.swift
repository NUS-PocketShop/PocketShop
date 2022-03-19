import Combine
import SwiftUI

class RegisterViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading = false
    @Published var isCustomer = true

    private(set) var viewRouter: MainViewRouter

    init(router: MainViewRouter) {
        self.viewRouter = router
    }

    func register() {
        self.isLoading = true
        if self.email.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty {
            self.setErrorMessage("Please enter all fields")
            return
        }
        if self.password != self.confirmPassword {
            self.setErrorMessage("Password and confirm password fields do not match")
            return
        }
        DatabaseInterface.auth.createNewAccount(email: self.email, password: self.password,
                                                isCustomer: isCustomer) { error, user in
            switch error {
            case .invalidEmail:
                self.setErrorMessage("Please enter a valid email address")
                return
            case .weakPassword:
                self.setErrorMessage("Weak password")
                return
            case .emailAlreadyInUse:
                self.setErrorMessage("A user with this email already exists")
                return
            case .unexpectedError:
                self.setErrorMessage("Unexpected error")
                return
            default:
                self.setErrorMessage("")
            }
            if let customer = user as? Customer {
                print("Customer successfully loaded with id: \(customer.id)")
                self.viewRouter.currentPage = .customer
            } else if let vendor = user as? Vendor {
                print("Vendor successfully loaded with id: \(vendor.id)")
                // self.viewRouter.currentPage = .vendor
            } else {
                self.setErrorMessage("Unexpected error")
            }
        }
    }

    private func setErrorMessage(_ message: String) {
        self.errorMessage = message
        self.isLoading = false
    }

}
