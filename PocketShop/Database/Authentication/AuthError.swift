enum AuthError: Error {
    case invalidEmail
    case emailAlreadyInUse
    case weakPassword
    case wrongPassword
}
