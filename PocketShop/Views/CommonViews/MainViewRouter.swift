import SwiftUI

class MainViewRouter: ObservableObject {

    @Published var currentPage: Page = .login

    enum Page {
        case login
        case customer
        case vendor
    }

}
