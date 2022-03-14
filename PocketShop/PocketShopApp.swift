import SwiftUI

@main
struct PocketShopApp: App {

    @StateObject var mainViewRouter = MainViewRouter()

    var body: some Scene {
        WindowGroup {
            ContentView(viewRouter: mainViewRouter)
        }
    }
}
