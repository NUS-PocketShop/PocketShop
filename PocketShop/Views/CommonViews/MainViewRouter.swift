import SwiftUI

class MainViewRouter: ObservableObject {

    @Published var currentPage: Page = .login

    init() {
        DatabaseInterface.auth.getCurrentUser { _, user in
            if user as? Customer != nil {
                self.currentPage = .customer
            } else if user as? Vendor != nil {
                self.currentPage = .vendor
            }
        }
    }

    enum Page {
        case login
        case customer
        case vendor
    }

}
