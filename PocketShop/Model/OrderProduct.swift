struct OrderProduct: Hashable, Identifiable {
    var id: String
    var product: Product
    var quantity: Int
    var status: OrderStatus
    var total: Double
}
