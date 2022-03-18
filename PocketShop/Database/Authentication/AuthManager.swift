import Firebase

class AuthManager: AuthAdapter {
    static let sharedAuthManager = AuthManager()
    private init() {}

    func createNewAccount(email: String, password: String, isCustomer: Bool,
                          completionHandler: @escaping (AuthError?, User?) -> Void) {
        FirebaseManager.sharedManager.auth.createUser(withEmail: email, password: password) { result, err in
            if let error = err, let errCode = AuthErrorCode(rawValue: error._code) {
                completionHandler(self.getAuthError(errorCode: errCode), nil)
                return
            }
            let id: String = result?.user.uid ?? ""
            if isCustomer {
                let newCustomer = Customer(id: id)

                print("Successfully created customer: \(id)")
                DatabaseInterface.db.createCustomer(customer: newCustomer)
                completionHandler(nil, newCustomer)
            } else {
                let newVendor = Vendor(id: id)

                print("Successfully created vendor: \(id)")
                DatabaseInterface.db.createVendor(vendor: newVendor)
                completionHandler(nil, newVendor)
            }

        }
    }

    func loginUser(email: String, password: String, completionHandler: @escaping (AuthError?, User?) -> Void) {
        FirebaseManager.sharedManager.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err, let errCode = AuthErrorCode(rawValue: err._code) {
                print(err._code)
                completionHandler(self.getAuthError(errorCode: errCode), nil)
                return
            }
            let id: String = result?.user.uid ?? ""
            DatabaseInterface.db.getUser(with: id) { error, user in
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
                completionHandler(nil, user)
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

    func getCurrentUser(completionHandler: @escaping (AuthError?, User?) -> Void) {
        guard let currentFBUser = FirebaseManager.sharedManager.auth.currentUser else {
            completionHandler(.userNotFound, nil)
            return
        }
        DatabaseInterface.db.getUser(with: currentFBUser.uid) { error, user in
            if let error = error {
                if error == .userNotFound {
                    completionHandler(.userNotFound, nil)
                } else {
                    completionHandler(.unexpectedError, nil)
                }
                return
            }
            completionHandler(nil, user)
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
