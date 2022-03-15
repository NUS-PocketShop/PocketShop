protocol AuthAdapter {
    func createNewAccount(email: String, password: String, completionHandler: @escaping (AuthError?, Customer?) -> Void)
    func loginUser(email: String, password: String, completionHandler: @escaping (AuthError?, Customer?) -> Void)
    func signOutUser()
}
