import Combine
import SwiftUI

class RegisterViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""

    private(set) var viewRouter: MainViewRouter

    init(router: MainViewRouter) {
        self.viewRouter = router
    }

    func register() {
        if self.password != self.confirmPassword {
            print("password and confirm password fields do not match")
            return
        }
        DatabaseInterface.auth.createNewAccount(email: self.email, password: self.password) { error, customer in
            switch error {
            case .invalidEmail:
                print("invalid email")
                return
            case .weakPassword:
                print("weak password")
                return
            case .emailAlreadyInUse:
                print("email already in use")
                return
            case .unexpectedError:
                print("unexpected error")
                return
            default:
                break
            }
            if let customer = customer {
                print("Customer successfully created with id: \(customer.id)")
            }
            print("registering with: [\(self.email) & \(self.password)]")
            // TODO: get user type
            self.viewRouter.currentPage = .customer
        }
    }

}
