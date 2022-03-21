import SwiftUI

struct ShopProductFormView: View {
    @StateObject var viewModel: VendorViewModel
    @Binding var showModal: Bool

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var description: String = ""
    @State private var prepTime: String = ""
    @State private var image: UIImage?

    var body: some View {
        Group {
            if showModal {
                ZStack {
                    Color.white
                        .ignoresSafeArea()

                    VStack {
                        PSTextField(text: $name,
                                    title: "Product Name",
                                    placeholder: "Enter product name")

                        PSTextField(text: $price,
                                    title: "Product Price",
                                    placeholder: "Enter product price")

                        PSTextField(text: $description,
                                    title: "Product Description (optional)",
                                    placeholder: "Enter product description")

                        PSTextField(text: $prepTime,
                                    title: "Estimated Prep Time",
                                    placeholder: "Enter estimated prep time")

                        PSImagePicker(title: "Product Image",
                                      image: $image)
                            .padding(.bottom)

                        PSButton(title: "Save") {
                            guard let image = image, !name.isEmpty else {
                                return
                            }
                            guard let price = Double(price) else {
                                return
                            }
                            guard let estimatedPrepTime = Double(prepTime) else {
                                return
                            }
                            // Create Product and save to db
                            viewModel.createProduct(name: name,
                                                    description: description,
                                                    price: price,
                                                    estimatedPrepTime: estimatedPrepTime,
                                                    image: image)
                            showModal = false
                        }
                        .buttonStyle(FillButtonStyle())
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
