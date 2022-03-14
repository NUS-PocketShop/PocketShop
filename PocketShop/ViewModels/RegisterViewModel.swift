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
        // TODO: check if valid
        print("registering with: [\(self.email) & \(self.password)]")
        // TODO: get user type
        viewRouter.currentPage = .customer
    }

}
