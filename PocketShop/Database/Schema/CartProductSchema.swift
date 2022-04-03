struct CartProductSchema: Codable {
    var id: String
    var quantity: Int

    var productName: String
    var productPrice: Double
    var productImageURL: String
    var productOptionChoices: [Int: ProductOptionChoice]? = [:]

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

        var counter = 0
        for productOptionChoice in cartProduct.productOptionChoices {
            self.productOptionChoices?[counter] = productOptionChoice
            counter += 1
        }
    }

    func toCartProduct() -> CartProduct {
        let productOptionChoices = Array((self.productOptionChoices ?? [:]).values)
        return CartProduct(id: self.id,
                           quantity: self.quantity,
                           total: self.productPrice * Double(self.quantity),
                           productName: self.productName,
                           productPrice: self.productPrice,
                           productImageURL: self.productImageURL,
                           productOptionChoices: productOptionChoices,
                           shopName: self.shopName,
                           productId: self.productId, shopId: self.shopId)
    }
}
