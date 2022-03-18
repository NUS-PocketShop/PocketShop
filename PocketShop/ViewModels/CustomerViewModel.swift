import Combine

class CustomerViewModel: ObservableObject {

    @Published var products: [Product] = [Product]()
    @Published var customer: Customer?

    @Published var searchText = ""

    var productSearchResults: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    init() {
        generateSampleProducts()
        DatabaseInterface.auth.getCurrentUser() { _, user in
            if let customer = user as? Customer {
                self.customer = customer
            }
        }
    }

    /// Function used in development to generate sample products
    func generateSampleProducts() {
        let strawberryMilkTea = Product(id: "gc_strawberryMilkTea",
                                        name: "Strawberry Milk Tea",
                                        shopName: "Gong Cha",
                                        shopId: "",
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
                                          shopId: "",
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
                              shopId: "",
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
                             shopId: "",
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
                                           shopId: "",
                                           description: "Classic black milk tea with boba",
                                           price: 3.50,
                                           imageURL: """
                                                     http://www.gong-cha-sg.com/wp-content/uploads/2017/11/1.png
                                                     """,
                                           estimatedPrepTime: 2.5,
                                           isOutOfStock: false)

        products = [strawberryMilkTea, chiChaBubbleMilkTea, mcspicy, bigmac, gongChaBubbleMilkTea]
    }

}
