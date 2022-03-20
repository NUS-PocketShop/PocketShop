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

        // input check
        guard loginInputChecks() else {
            return
        }

        // service call
        DatabaseInterface.auth.loginUser(email: self.email, password: self.password) { [self] error, user in
            guard ensureNoLoginErrors(error) else {
                return
            }

            if let customer = user as? Customer {
                print("Customer successfully loaded with id: \(customer.id)")
                navigateToNextScreen(accountType: .customer)
            } else if let vendor = user as? Vendor {
                print("Vendor successfully loaded with id: \(vendor.id)")
                navigateToNextScreen(accountType: .vendor)
            } else {
                setErrorMessage("Unexpected error in LoginViewModel")
                return
            }
        }
    }

    // returns true if no errors
    private func ensureNoLoginErrors(_ error: AuthError?) -> Bool {
        switch error {
        case .wrongPassword:
            setErrorMessage("Wrong password")
        case .invalidEmail:
            setErrorMessage("Invalid email")
        case .userNotFound:
            setErrorMessage("User not found")
        case .unexpectedError:
            setErrorMessage("Unexpected error")
        default:
            setErrorMessage("")
            return true
        }
        return false
    }

    private func loginInputChecks() -> Bool {
        if email.isEmpty {
            setErrorMessage("Please enter an email")
        } else if password.isEmpty {
            setErrorMessage("Please enter your password")
        } else {
            return true
        }
        return false
    }

    private func navigateToNextScreen(accountType: AccountType) {
        switch accountType {
        case .vendor:
            viewRouter.currentPage = .vendor
        default:
            viewRouter.currentPage = .customer
        }
    }

    private func setErrorMessage(_ message: String) {
        self.errorMessage = message
        self.isLoading = false
    }

}
