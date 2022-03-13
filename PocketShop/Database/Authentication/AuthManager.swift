import Firebase

class AuthManager: AuthAdapter {
    static let sharedAuthManager = AuthManager()
    private init() {}
    
    func createNewAccount(email: String, password: String) throws {
        var returnError: AuthErrorCode?
        FirebaseManager.sharedManager.auth.createUser(withEmail: email, password: password) { result, err in
            if let error = err, let errCode = AuthErrorCode(rawValue: error._code) {
                returnError = errCode
                return
            }
            let id: String = result?.user.uid ?? ""
            print("Successfully created user: \(id)")
            DatabaseManager.sharedDatabaseManager.createCustomer(customer: Customer(id: id))
        }
        if let returnError = returnError {
            guard let throwError = getAuthError(errorCode: returnError) else {
                print("Unexpected error: \(returnError)")
                return
            }
            throw throwError
        }
        
    }
    
    func loginUser(email: String, password: String) throws {
        var returnError: AuthErrorCode?
        FirebaseManager.sharedManager.auth.signIn(withEmail: email, password: password) { result, err in
            if let error = err, let errCode = AuthErrorCode(rawValue: error._code) {
                returnError = errCode
                return
            }
            print("Successfully logged in user: \(result?.user.uid ?? "")")
        }
        if let returnError = returnError {
            guard let throwError = getAuthError(errorCode: returnError) else {
                print("Unexpected error: \(returnError)")
                return
            }
            throw throwError
        }
    }
    
    private func getAuthError(errorCode: AuthErrorCode) -> AuthError? {
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .wrongPassword:
            return .wrongPassword
        default:
            return nil
        }
    }
}
