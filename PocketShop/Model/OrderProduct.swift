struct OrderProduct: Hashable, Identifiable {
    var id: String
    var product: Product
    var quantity: Int
    var status: OrderStatus
    var total: Double

    static func == (lhs: OrderProduct, rhs: OrderProduct) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
