class DatabaseInterface {
    static let auth: AuthAdapter = AuthManager.sharedAuthManager
    static let db: DatabaseAdapter = DatabaseManager.sharedDatabaseManager
}
