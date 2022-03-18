import Combine
import SwiftUI

enum AccountType: String {
    case customer = "Customer"
    case vendor = "Vendor"
}

class RegisterViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var accountType: AccountType?
    @Published var errorMessage: String = ""
    @Published var isLoading = false

    private(set) var viewRouter: MainViewRouter

    init(router: MainViewRouter) {
        self.viewRouter = router
        self.accountType = nil
    }

    func register() {
        self.isLoading = true

        // Sanity checks
        guard registerInputChecks() else {
            return
        }
        guard let type = accountType else {
            setErrorMessage("Please select an account type first")
            return
        }

        // Service call
        // TODO: to handle isCustomer/isVendor in the createNewAccount call
        DatabaseInterface.auth.createNewAccount(email: self.email, password: self.password) { [self] error, customer in
            guard ensureNoRegisterErrors(error) else {
                return
            }

            if let customer = customer {
                print("Customer successfully created with id: \(customer.id)")
            }
            navigateToNextScreen(accountType: type)
        }
    }

    func setAccountType(_ type: String) {
        if type == "Vendor" {
            self.accountType = AccountType.vendor
        } else {
            self.accountType = AccountType.customer
        }
    }

    // returns true if no errors
    private func ensureNoRegisterErrors(_ error: AuthError?) -> Bool {
        switch error {
        case .invalidEmail:
            setErrorMessage("Please enter a valid email address")
        case .weakPassword:
            setErrorMessage("Weak password")
        case .emailAlreadyInUse:
            setErrorMessage("A user with this email already exists")
        case .unexpectedError:
            setErrorMessage("Unexpected error")
        default:
            setErrorMessage("")
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

    private func registerInputChecks() -> Bool {
        if email.isEmpty {
            setErrorMessage("Please enter an email")
        } else if password.isEmpty || confirmPassword.isEmpty {
            setErrorMessage("Please enter and confirm your password")
        } else if password != confirmPassword {
            setErrorMessage("Password and confirm password fields do not match")
        } else {
            return true
        }
        return false
    }

    private func setErrorMessage(_ message: String) {
        self.errorMessage = message
        self.isLoading = false
    }

}
