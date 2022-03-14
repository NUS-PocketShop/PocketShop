import SwiftUI

class CustomerViewRouter: ObservableObject {

    @Published var currentPage: Page = .home

    enum Page: Int {
        case home = 0
        case search = 1
        case cart = 2
        case profile = 3
    }

}
