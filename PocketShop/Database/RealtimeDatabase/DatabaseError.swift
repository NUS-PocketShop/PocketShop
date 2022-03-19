enum DatabaseError: Error {
    case unexpectedError
    case userNotFound
    case fileCouldNotBeUploaded
    case fileCouldNotBeDownloaded
}
