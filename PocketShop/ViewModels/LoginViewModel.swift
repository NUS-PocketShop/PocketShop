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
        DatabaseInterface.auth.loginUser(email: self.email, password: self.password) { error, customer in
            switch error {
            case .wrongPassword:
                self.setErrorMessage("Wrong password")
                return
            case .invalidEmail:
                self.setErrorMessage("Invalid email")
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
            if let customer = customer {
                print("Customer successfully loaded with id: \(customer.id)")
            }
            print("logging in with: [\(self.email) & \(self.password)]")
            // TODO: get user type
            self.viewRouter.currentPage = .customer
        }
    }

    private func setErrorMessage(_ message: String) {
        self.errorMessage = message
        self.isLoading = false
    }

}
