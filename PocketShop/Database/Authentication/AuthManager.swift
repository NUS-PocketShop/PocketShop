import Firebase

class AuthManager: AuthAdapter {
    static let sharedAuthManager = AuthManager()
    private init() {}

    func createNewAccount(email: String, password: String,
                          completionHandler: @escaping (AuthError?, Customer?) -> Void) {
        FirebaseManager.sharedManager.auth.createUser(withEmail: email, password: password) { result, err in
            if let error = err, let errCode = AuthErrorCode(rawValue: error._code) {
                completionHandler(self.getAuthError(errorCode: errCode), nil)
                return
            }
            let id: String = result?.user.uid ?? ""
            let newCustomer = Customer(id: id)

            print("Successfully created user: \(id)")
            DatabaseInterface.db.createCustomer(customer: newCustomer)
            completionHandler(nil, newCustomer)
        }
    }

    func loginUser(email: String, password: String, completionHandler: @escaping (AuthError?, Customer?) -> Void) {
        FirebaseManager.sharedManager.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err, let errCode = AuthErrorCode(rawValue: err._code) {
                print(err._code)
                completionHandler(self.getAuthError(errorCode: errCode), nil)
                return
            }
            let id: String = result?.user.uid ?? ""
            DatabaseInterface.db.getCustomer(with: id) { error, customer in
                if let error = error {
                    if error == .userNotFound {
                        let newCustomer = Customer(id: id)
                        DatabaseInterface.db.createCustomer(customer: newCustomer)
                        completionHandler(nil, newCustomer)
                        return
                    } else {
                        print("Unexpected error")
                        return
                    }
                }
                completionHandler(nil, customer)
                return
            }
        }
    }

    func signOutUser() {
        do {
            try FirebaseManager.sharedManager.auth.signOut()
            print("Successfully signed out")
        } catch {
            print("Unexpected error when signing out")
        }
    }

    private func getAuthError(errorCode: AuthErrorCode) -> AuthError {
        switch errorCode {
        case .userNotFound:
            return .userNotFound
        case .invalidEmail:
            return .invalidEmail
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .wrongPassword:
            return .wrongPassword
        default:
            return .unexpectedError
        }
    }
}
