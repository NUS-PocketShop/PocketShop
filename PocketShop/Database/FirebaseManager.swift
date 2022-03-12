import SwiftUI
import Firebase

class FirebaseManager: NSObject {
    let auth: Auth
    static let sharedManager = FirebaseManager()

    override init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        super.init()
    }

}
