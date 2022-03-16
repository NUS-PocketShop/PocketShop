import Combine
import SwiftUI

class RegisterViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading = false

    private(set) var viewRouter: MainViewRouter

    init(router: MainViewRouter) {
        self.viewRouter = router
    }

    func register() {
        self.isLoading = true
        if self.password != self.confirmPassword {
            self.setErrorMessage("Password and confirm password fields do not match")
            return
        }
        DatabaseInterface.auth.createNewAccount(email: self.email, password: self.password) { error, customer in
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
            if let customer = customer {
                print("Customer successfully created with id: \(customer.id)")
            }
            print("registering with: [\(self.email) & \(self.password)]")
            // TODO: get user type
            self.viewRouter.currentPage = .customer
        }
    }

    private func setErrorMessage(_ message: String) {
        self.errorMessage = message
        self.isLoading = false
    }

}
