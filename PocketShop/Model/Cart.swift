struct Cart: Hashable, Identifiable {
    var id: String
    var customerId: String
    var products: [Product: Int] // Product : Quantity
}
