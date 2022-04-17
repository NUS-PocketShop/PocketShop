/// Handles favouriting of products. Extensible to other items (favourite shops, locations, etc)
extension CustomerViewModel {
    func toggleProductAsFavorites(productId: ID) {
        if favourites.contains(where: { $0.id == productId }) {
            removeProductFromFavorites(productId: productId)
        } else {
            addProductToFavorites(productId: productId)
        }
    }

    func addProductToFavorites(productId: ID) {
        self.customer?.favouriteProductIds.append(productId)
        guard let customer = customer else {
            return
        }
        DatabaseInterface.db.setFavouriteProductIds(userId: customer.id,
                                                    favouriteProductIds: customer.favouriteProductIds)
    }

    func removeProductFromFavorites(productId: ID) {
        self.customer?.favouriteProductIds.removeAll(where: { $0 == productId })
        guard let customer = customer else {
            return
        }
        DatabaseInterface.db.setFavouriteProductIds(userId: customer.id,
                                                    favouriteProductIds: customer.favouriteProductIds)
    }

}
