protocol DatabaseAdapter {
    func createCustomer(customer: Customer)
    func getCustomer(with id: String, completionHandler: @escaping (DatabaseError?, Customer?) -> Void)
}
