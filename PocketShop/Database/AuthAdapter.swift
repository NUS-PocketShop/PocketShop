protocol AuthAdapter {
    func createNewAccount(email: String, password: String) throws
    func loginUser(email: String, password: String) throws
}
