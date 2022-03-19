enum AuthError: Error {
    case unexpectedError
    case userNotFound
    case invalidEmail
    case emailAlreadyInUse
    case weakPassword
    case wrongPassword
}
