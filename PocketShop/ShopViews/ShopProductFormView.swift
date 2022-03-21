import SwiftUI

struct ShopProductFormView: View {
    @StateObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var description: String = ""
    @State private var prepTime: String = ""
    @State private var image: UIImage?

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add new product")
                    .font(.appTitle)

                UserInputSegment(name: $name,
                                 price: $price,
                                 description: $description,
                                 prepTime: $prepTime)

                PSImagePicker(title: "Product Image",
                              image: $image)
                    .padding(.bottom)

                PSButton(title: "Save") {
                    guard let image = image, !name.isEmpty,
                          let price = Double(price),
                          let estimatedPrepTime = Double(prepTime) else {
                        return
                    }
                    // Create Product and save to db
                    viewModel.createProduct(name: name,
                                            description: description,
                                            price: price,
                                            estimatedPrepTime: estimatedPrepTime,
                                            image: image)
                    presentationMode.wrappedValue.dismiss()

                }
                .buttonStyle(FillButtonStyle())
            }
            .padding()
        }
        .navigationBarItems(trailing: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

struct UserInputSegment: View {

    @Binding var name: String
    @Binding var price: String
    @Binding var description: String
    @Binding var prepTime: String

    var body: some View {
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
        }
    }
}
