import Combine
import SwiftUI

class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading = false

    private(set) var viewRouter: MainViewRouter

    init(router: MainViewRouter) {
        self.viewRouter = router
    }

    func login() {
        self.isLoading = true
        if self.email.isEmpty || self.password.isEmpty {
            self.setErrorMessage("Please enter all fields")
            return
        }
        DatabaseInterface.auth.loginUser(email: self.email, password: self.password) { error, user in
            switch error {
            case .invalidEmail:
                self.setErrorMessage("Invalid email")
                return
            case .wrongPassword:
                self.setErrorMessage("Wrong password")
                return
            case .userNotFound:
                self.setErrorMessage("User not found")
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
