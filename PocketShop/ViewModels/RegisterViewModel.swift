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

    private(set) var viewRouter: MainViewRouter

    init(router: MainViewRouter) {
        self.viewRouter = router
    }

    func register() {
        // TODO: check if valid
        print("registering with: [\(self.email) & \(self.password)]")
        // TODO: get user type

        guard let type = accountType else {
            print("please select an account type first")
            return
        }

        switch type {
        case .vendor:
            viewRouter.currentPage = .vendor
        default:
            viewRouter.currentPage = .customer
        }
    }

    func setAccountType(_ type: String) {
        if type == "Vendor" {
            self.accountType = AccountType.vendor
        } else {
            self.accountType = AccountType.customer
        }
    }

}
