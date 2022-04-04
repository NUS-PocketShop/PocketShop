struct CartProductSchema: Codable {
    var id: String
    var quantity: Int

    var productName: String
    var productPrice: Double
    var productImageURL: String
    var productOptionChoices: [ProductOptionChoice]? = []

    var shopName: String

    var productId: String
    var shopId: String

    init(cartProduct: CartProduct) {
        self.id = cartProduct.id
        self.quantity = cartProduct.quantity
        self.productName = cartProduct.productName
        self.productPrice = cartProduct.productPrice
        self.productImageURL = cartProduct.productImageURL
        self.shopName = cartProduct.shopName
        self.productId = cartProduct.productId
        self.shopId = cartProduct.shopId
        self.productOptionChoices = cartProduct.productOptionChoices
    }

    func toCartProduct() -> CartProduct {
        CartProduct(id: self.id,
                    quantity: self.quantity,
                    productName: self.productName,
                    productPrice: self.productPrice,
                    productImageURL: self.productImageURL,
                    productOptionChoices: self.productOptionChoices ?? [],
                    shopName: self.shopName,
                    productId: self.productId, shopId: self.shopId)
    }
}
