import Combine
import SwiftUI

class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""

    private(set) var viewRouter: MainViewRouter

    init(router: MainViewRouter) {
        self.viewRouter = router
    }

    func login() {
        // TODO: handle errors
        DatabaseInterface.auth.loginUser(email: self.email, password: self.password) { error, customer in
            switch error {
            case .wrongPassword:
                print("wrong password")
                return
            case .invalidEmail:
                print("invalid email")
                return
            case .userNotFound:
                print("user not found")
                return
            case .unexpectedError:
                print("unexpected error")
                return
            default:
                break
            }
            if let customer = customer {
                print("Customer successfully loaded with id: \(customer.id)")
            }
            print("logging in with: [\(self.email) & \(self.password)]")
            // TODO: get user type
            self.viewRouter.currentPage = .customer
        }
    }

}
