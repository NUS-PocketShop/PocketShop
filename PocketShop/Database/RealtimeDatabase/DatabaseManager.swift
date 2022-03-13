class DatabaseManager: DatabaseAdapter {
    static let sharedDatabaseManager = DatabaseManager()
    private init() {}
    
    let users = Users()
    
    func createCustomer(customer: Customer) {
        users.createCustomer(id: customer.id)
    }
    
}
