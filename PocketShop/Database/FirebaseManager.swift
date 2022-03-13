import SwiftUI
import Firebase

class FirebaseManager: NSObject {
    let auth: Auth
    var ref: DatabaseReference
    static let sharedManager = FirebaseManager()

    override private init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.ref = Database.database().reference()
        super.init()
    }

}
