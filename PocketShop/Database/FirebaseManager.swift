import SwiftUI
import Firebase

class FirebaseManager: NSObject {
    let auth: Auth
    var ref: DatabaseReference
    static let sharedManager = FirebaseManager()

    override private init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.ref = Database
            .database(url: "https://pocketshop-3318b-default-rtdb.asia-southeast1.firebasedatabase.app")
            .reference()
        super.init()
    }

}
