import Firebase

class FirebaseAuth {
    func createNewAccount(email: String, password: String) {
        var returnError: AuthErrorCode? // TODO decide how to throw error
        FirebaseManager.sharedManager.auth.createUser(withEmail: email, password: password) { result, err in
            if let error = err {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    returnError = errCode
                }
            }
            print("Successfully created user: \(result?.user.uid ?? "")")
        }
    }
    
    func loginUser(email: String, password: String) {
        var returnError: AuthErrorCode? // TODO decide how to throw error
        FirebaseManager.sharedManager.auth.signIn(withEmail: email, password: password) { result, err in
            if let error = err {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    returnError = errCode
                }
            }
            print("Successfully logged in user: \(result?.user.uid ?? "")")
        }
    }
}
