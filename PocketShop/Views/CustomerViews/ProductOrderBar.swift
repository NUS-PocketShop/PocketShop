import SwiftUI

struct ProductOrderBar: View {
    @EnvironmentObject var customerViewModel: CustomerViewModel
    @State var quantity: Int = 1
    var product: Product

    var body: some View {
        HStack {
            VStack {
                // Quantity
                Text("Quantity")
                    .font(.appHeadline)
                HStack {
                    PSButton(title: "-") {
                        if quantity > 1 { quantity -= 1 }
                    }
                    .buttonStyle(OutlineButtonStyle())
                    Text(String(quantity))
                        .font(.appButton)
                        .padding(.horizontal)
                    PSButton(title: "+") {
                        if quantity < 1_000 { quantity += 1 }
                    }
                    .buttonStyle(OutlineButtonStyle())
                }
            }
            .padding(.horizontal)

            VStack {
                // Price and order button
                Text(String(format: "Price: $%.2f", product.price * Double(quantity)))
                    .font(.appHeadline)
                PSButton(title: "ORDER") {
                    guard let customerId = customerViewModel.customer?.id else {
                        // TODO: More helpful error message
                        return
                    }

                    let orderProduct = OrderProduct(id: "dummyId",
                                                    quantity: quantity,
                                                    status: .pending,
                                                    total: 0,
                                                    productName: product.name,
                                                    productPrice: product.price,
                                                    productImageURL: product.imageURL,
                                                    productOptionChoices: [],
                                                    productId: product.id,
                                                    shopId: product.shopId)
                    let order = Order(id: "dummyId",
                                      orderProducts: [orderProduct],
                                      status: .pending,
                                      customerId: customerId,
                                      shopId: product.shopId,
                                      shopName: product.shopName,
                                      date: Date(),
                                      collectionNo: 0,
                                      total: 0)

                    DatabaseInterface.db.createOrder(order: order)
                }
                .buttonStyle(FillButtonStyle())
            }
            .padding()
        }
        .padding(.bottom)
    }
}
