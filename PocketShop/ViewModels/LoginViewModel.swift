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
        print("logging in with: [\(self.email) & \(self.password)]")
        // TODO: get user type
        viewRouter.currentPage = .customer
    }

}
