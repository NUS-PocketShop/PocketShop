import SwiftUI

class ShopViewRouter: ObservableObject {

    @Published var currentPage: Page = .home

    enum Page: Int {
        case home = 0
        case orders = 1
        case profile = 2
    }

}
