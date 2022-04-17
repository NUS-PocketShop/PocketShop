import Foundation
import SwiftUI

/// Manage current inventory
/// For example, adding/editing products
extension VendorViewModel {
    func createProduct(product: Product, image: UIImage) {
        guard let shop = currentShop else {
            print("No current shop!")
            return
        }

        DatabaseInterface.db.createProduct(shopId: shop.id, product: product, imageData: image.pngData())
    }

    func editProduct(newProduct: Product, image: UIImage) {
        guard let shop = currentShop else {
            print("No current shop!")
            return
        }

        DatabaseInterface.db.editProduct(shopId: shop.id, product: newProduct, imageData: image.pngData())
    }

    func deleteProduct(category: ShopCategory, at positions: IndexSet) {
        for index in positions {
            guard let shopId = currentShop?.id else {
                return
            }
            let idToDelete = getOrderedCategoryProducts(category: category)[index].id
            DatabaseInterface.db.deleteProduct(shopId: shopId, productId: idToDelete)
        }
    }

    func toggleProductStockStatus(product: Product) {
        if product.isOutOfStock {
            setProductInStock(product: product)
        } else {
            setProductOutOfStock(product: product)
        }
    }

    func setAllProductsToInStock() {
        if let currentShop = currentShop {
            DatabaseInterface.db.setAllProductsInShopToInStock(shopId: currentShop.id)
        }
    }

    func addTagToProduct(product: Product, tag: ProductTag) {
        var oldTags = product.tags
        oldTags.append(tag)
        DatabaseInterface.db.setProductTags(shopId: product.shopId, productId: product.id, tags: oldTags)
    }

    func deleteTagFromProduct(product: Product, tag: ProductTag) {
        var oldTags = product.tags
        oldTags.removeAll(where: { $0 == tag })
        DatabaseInterface.db.setProductTags(shopId: product.shopId, productId: product.id, tags: oldTags)
    }

    func moveProducts(category: ShopCategory, source: IndexSet, destination: Int) {
        guard let currentShop = currentShop else {
            return
        }
        var categoryProducts = getOrderedCategoryProducts(category: category)
        categoryProducts.move(fromOffsets: source, toOffset: destination)
        for index in 0..<categoryProducts.count {
            DatabaseInterface.db.setProductOrderingIndex(shopId: currentShop.id,
                                                         productId: categoryProducts[index].id,
                                                         index: index)
        }
    }

    private func setProductOutOfStock(product: Product) {
        DatabaseInterface.db.setProductToOutOfStock(shopId: product.shopId, productId: product.id)
        for otherProduct in products where otherProduct.isComboMeal && otherProduct.subProductIds.contains(product.id) {
            DatabaseInterface.db.setProductToOutOfStock(shopId: product.shopId, productId: otherProduct.id)
        }
    }

    private func setProductInStock(product: Product) {
        DatabaseInterface.db.setProductToInStock(shopId: product.shopId, productId: product.id)
        if product.isComboMeal {
            for subProductId in product.subProductIds {
                DatabaseInterface.db.setProductToInStock(shopId: product.shopId, productId: subProductId)
            }
        }
    }
}
