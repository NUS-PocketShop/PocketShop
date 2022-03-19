import Combine

class CustomerViewModel: ObservableObject {

    @Published var products: [Product] = [Product]()
    @Published var shops: [Shop] = [Shop]()

    @Published var searchText = ""

    var productSearchResults: [Product] {
        if searchText.isEmpty {
            return Array(products)
        } else {
            return Array(products.filter { $0.name.localizedCaseInsensitiveContains(searchText) })
        }
    }

    var shopSearchResults: [Shop] {
        if searchText.isEmpty {
            return Array(shops)
        } else {
            return Array(shops.filter { shop in
                let productIds = Set(shop.soldProductIds)
                let shopProducts = products.filter { productIds.contains($0.id) }
                let matchingProducts = shopProducts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                return !matchingProducts.isEmpty
            })
        }
    }

    init() {
        initSampleProducts()
        initSampleShops()
    }

    /// Function used in development to generate sample products
    func initSampleProducts() {
        let strawberryMilkTea = Product(id: "gc_strawberryMilkTea",
                                        name: "Strawberry Milk Tea",
                                        shopName: "Gong Cha",
                                        description: "Contains real strawberries",
                                        price: 7.90,
                                        imageURL: """
                                                  https://gongchausa.com/wp-content/
                                                  uploads/2022/01/Strawberry-Milk-Tea.png
                                                  """,
                                        estimatedPrepTime: 3.0,
                                        isOutOfStock: false)

        let chiChaBubbleMilkTea = Product(id: "cc_bubbleMilkTea",
                                          name: "Bubble Milk Tea",
                                          shopName: "CHICHA San Chen",
                                          description: "Black milk tea with pearls",
                                          price: 4.50,
                                          imageURL: """
                                                    http://sethlui.com/wp-content/uploads/2019/04/chicha-san-chen-
                                                    taiwan-bubble-tea-new-singapore-outlet-may-2019-online-7.jpg
                                                    """,
                                          estimatedPrepTime: 3.0,
                                          isOutOfStock: false)

        let mcspicy = Product(id: "mcd_mcspicy",
                              name: "McSpicy",
                              shopName: "McDonald's",
                              description: "Spicy chicken sandwich",
                              price: 5.25,
                              imageURL: """
                                        https://goodyfeed.com/wp-content/uploads/2020/10/mcspicy.png
                                        """,
                              estimatedPrepTime: 1.5,
                              isOutOfStock: false)

        let bigmac = Product(id: "mcd_bigMac",
                             name: "Big Mac",
                             shopName: "McDonald's",
                             description: "Classic double-patty burger",
                             price: 5.75,
                             imageURL: """
                                       https://s7d1.scene7.com/is/image/mcdonalds/t-mcdonalds-Big-Mac-1:
                                       1-3-product-tile-desktop?wid=830&hei=516&dpr=off
                                       """,
                             estimatedPrepTime: 2.0,
                             isOutOfStock: false)

        let gongChaBubbleMilkTea = Product(id: "gc_bubbleMilkTea",
                                           name: "Bubble Milk Tea",
                                           shopName: "Gong Cha",
                                           description: "Classic black milk tea with boba",
                                           price: 3.50,
                                           imageURL: """
                                                     http://www.gong-cha-sg.com/wp-content/uploads/2017/11/1.png
                                                     """,
                                           estimatedPrepTime: 2.5,
                                           isOutOfStock: false)

        products = [strawberryMilkTea, chiChaBubbleMilkTea, mcspicy, bigmac, gongChaBubbleMilkTea]
    }

    func addGongChaShop() {
        let gongCha = Shop(id: "gc",
                           name: "Gong Cha",
                           description: "UTown",
                           imageURL: """
                                     http://www.gong-cha-sg.com/wp-content/plugins/agile-store-locator/public/Logo/
                                     5a4f4dbd345bb_logo.png
                                     """,
                           isClosed: false,
                           ownerId: "gc_vendor01",
                           soldProductIds: ["gc_strawberryMilkTea", "gc_bubbleMilkTea"])
        shops.append(gongCha)
    }

    func addMcDonaldsShop() {
        let mcd = Shop(id: "mcd",
                       name: "McDonald's",
                       description: "Punggol Plaza",
                       imageURL: """
                                 https://yt3.ggpht.com/ytc/AKedOLTkYnULPQlg8T4kW26XHKbOsJyREZ7waqnqZadL
                                 =s900-c-k-c0x00ffffff-no-rj
                                 """,
                       isClosed: false,
                       ownerId: "mcd_vendor01",
                       soldProductIds: ["mcd_mcspicy", "mcd_bigMac"])
        shops.append(mcd)
    }

    func addChiChaShop() {
        let chiCha = Shop(id: "cc",
                          name: "CHICHA San Chen",
                          description: "313@somerset",
                          imageURL: """
                                    https://singapore-river.sg/wp-content/uploads/2020/10/cqc-chichasanchen.jpg
                                    """,
                          isClosed: false,
                          ownerId: "cc_vendor01",
                          soldProductIds: ["cc_bubbleMilkTea"])
        shops.append(chiCha)
    }

    func initSampleShops() {
        shops.removeAll()
        addGongChaShop()
        addMcDonaldsShop()
        addChiChaShop()
    }

}
