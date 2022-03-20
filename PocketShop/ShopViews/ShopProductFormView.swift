import SwiftUI

struct ShopProductFormView: View {
    @StateObject var viewModel: VendorViewModel
    @Binding var showModal: Bool

    @State private var name: String = ""
    @State private var price: String = ""

    var body: some View {
        Group {
            if showModal {
                ZStack {
                    Color.white
                        .ignoresSafeArea()

                    VStack {
                        Text("PRODUCT NAME")
                            .font(.appHeadline)
                        PSTextField(text: $name, placeholder: "Enter product name")

                        Text("PRODUCT PRICE")
                            .font(.appHeadline)
                        PSTextField(text: $price, placeholder: "Enter product price")

                        Text("PRODUCT IMAGE")
                            .font(.appHeadline)

                        PSButton(title: "Upload image", icon: "plus") {
                            // Upload image

                        }
                        .buttonStyle(OutlineButtonStyle())
                        .padding(.bottom)

                        PSButton(title: "Save") {
                            // Create Product and save to db

                            showModal = false
                        }
                        .buttonStyle(FillButtonStyle())
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}
