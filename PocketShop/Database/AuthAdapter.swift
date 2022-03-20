protocol AuthAdapter {
    func createNewAccount(email: String, password: String, isCustomer: Bool,
                          completionHandler: @escaping (AuthError?, User?) -> Void)
    func loginUser(email: String, password: String, completionHandler: @escaping (AuthError?, User?) -> Void)
    func signOutUser()
    func getCurrentUser(completionHandler: @escaping (AuthError?, User?) -> Void)
}
