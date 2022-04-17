import Foundation
import Combine

final class CustomerViewModel: ObservableObject {

    @Published var products: [Product] = [Product]()
    @Published var shops: [Shop] = [Shop]()
    @Published var orders: [Order] = [Order]()
    @Published var cart: [CartProduct] = [CartProduct]()
    @Published var locations: [Location] = [Location]()
    @Published var coupons: [Coupon] = [Coupon]()
    @Published var customer: Customer?
    @Published var searchText = ""

    init() {
        var initializing = true
        DatabaseInterface.auth.getCurrentUser { [self] error, user in
            guard resolveErrors(error) else {
                return
            }
            if let currentCustomer = user as? Customer {
                customer = currentCustomer
                if initializing {
                    observeOrders(customerId: currentCustomer.id)
                    observeCart(customerId: currentCustomer.id)
                }
                initializing = false
            }
        }
        observeProducts()
        observeShops()
        observeLocations()
        observeCoupons()
    }

    func cancelOrder(orderId: ID) {
        DatabaseInterface.db.cancelOrder(id: orderId)
    }

    func getProductFor(cartProduct: CartProduct) -> Product {
        guard let product = products.first(where: { $0.id == cartProduct.productId }) else {
            fatalError("No product \(cartProduct.productId) exists!")
        }

        return product
    }

    func getOrderedCategoryProducts(shop: Shop, category: ShopCategory) -> [Product] {
        let products = shop.soldProducts
        return products.filter { $0.shopCategory?.title == category.title }
                       .sorted { $0.categoryOrderingIndex < $1.categoryOrderingIndex }
    }

    func getLocationNameFromLocationId(locationId: ID) -> String {
        locations.first(where: { $0.id == locationId })?.name ?? ""
    }

    func getLocationNameFromProduct(product: Product) -> String {
        let shop = shops.first(where: { $0.id == product.shopId })
        return locations.first(where: { $0.id == shop?.locationId })?.name ?? ""
    }

    func getLocationNameFromShopId(shopId: ID) -> String {
        let shop = shops.first(where: { $0.id == shopId })
        return locations.first(where: { $0.id == shop?.locationId })?.name ?? ""
    }

    func getProductFromProductId(productId: ID) -> Product? {
        let product = products.first(where: { $0.id == productId })
        return product
    }

}

extension CustomerViewModel {
    // Computed properties
    var productSearchResults: [Product] {
        let defaultSearchResults = products.filter { product in
            let shopIsNotClosed = !(shops.first(where: { $0.id == product.shopId })?.isClosed ?? true)
            return !product.isOutOfStock && shopIsNotClosed
        }
        if searchText.isEmpty {
            return defaultSearchResults
        } else {
            return defaultSearchResults.filter { product in
                let productNameMatches = product.name.localizedCaseInsensitiveContains(searchText)
                let productTagMatches = product.tags.contains(where: {
                    $0.tag.localizedCaseInsensitiveContains(searchText)
                })
                let productShopNameMatches = product.shopName.localizedCaseInsensitiveContains(searchText)
                let productShopLocationNameMatches = getLocationNameFromShopId(shopId: product.shopId)
                    .localizedCaseInsensitiveContains(searchText)
                return (productNameMatches || productTagMatches
                        || productShopNameMatches || productShopLocationNameMatches)
            }
        }
    }

    var shopSearchResults: [Shop] {
        if searchText.isEmpty {
            return shops
        } else {
            return shops.filter { shop in
                let shopNameMatches = shop.name.localizedCaseInsensitiveContains(searchText)
                let shopAnyProductNameMatches = shop.soldProducts.contains(where: {
                    $0.name.localizedCaseInsensitiveContains(searchText)
                })
                let shopAnyProductTagMatches = shop.soldProducts.contains(where: {
                    $0.tags.contains(where: { $0.tag.localizedCaseInsensitiveContains(searchText) })
                })
                let shopLocationNameMatches = getLocationNameFromLocationId(locationId: shop.locationId)
                    .localizedCaseInsensitiveContains(searchText)
                return shopNameMatches || shopAnyProductNameMatches
                || shopAnyProductTagMatches || shopLocationNameMatches
            }
        }
    }

    var locationSearchResults: [Location] {
        if searchText.isEmpty {
            return locations
        } else {
            return locations.filter { location in
                let locationNameMatches = location.name.localizedCaseInsensitiveContains(searchText)
                let locationAnyShopMatches = shops.contains(where: {
                    $0.locationId == location.id && $0.name.localizedCaseInsensitiveContains(searchText)
                })
                let locationAnyShopProductMatches = shops.contains(where: { shop in
                    shop.locationId == location.id && shop.soldProducts.contains(where: {
                        $0.name.localizedCaseInsensitiveContains(searchText)
                        || $0.tags.contains(where: { $0.tag.localizedCaseInsensitiveContains(searchText) })
                    })
                })
                return locationNameMatches || locationAnyShopMatches || locationAnyShopProductMatches
            }
        }
    }

    var favourites: [Product] {
        guard let customer = customer else {
            return []
        }
        return products.filter { customer.favouriteProductIds.contains($0.id) }
    }

    var customerCoupons: [Coupon] {
        guard let customer = customer else {
            return []
        }

        return coupons.filter { coupon in
            customer.couponIds[coupon.id] != nil && customer.couponIds[coupon.id] != 0
        }
    }
}
