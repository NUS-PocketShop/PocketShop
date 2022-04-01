import SwiftUI

struct ShopProductFormView: View {
    @StateObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var price = ""
    @State private var prepTime = ""
    @State private var description = ""
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

                PSImagePicker(title: "Product Image", image: $image)
                    .padding(.bottom)

                SaveNewProductButton(viewModel: viewModel, name: $name,
                                     price: $price, prepTime: $prepTime,
                                     description: $description, image: $image)
            }.padding()
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

struct SaveNewProductButton: View {
    @StateObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode

    @Binding var name: String
    @Binding var price: String
    @Binding var prepTime: String
    @Binding var description: String
    @Binding var image: UIImage?

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        PSButton(title: "Save") {
            guard !name.isEmpty else {
                alertMessage = "Product name cannot be empty!"
                showAlert = true
                return
            }

            guard let price = Double(price) else {
                alertMessage = price.isEmpty ? "Product price can't be empty!" : "Product price must be a valid double!"
                showAlert = true
                return
            }

            guard let estimatedPrepTime = Double(prepTime) else {
                alertMessage = prepTime.isEmpty ? "Product prep time can't be empty!"
                                                : "Product prep time must be a valid double!"
                showAlert = true
                return
            }

            guard let image = image else {
                alertMessage = "Missing product image!"
                showAlert = true
                return
            }

            // Create Product and save to db
            viewModel.createProduct(name: name, description: description, price: price,
                                    estimatedPrepTime: estimatedPrepTime, image: image)

            presentationMode.wrappedValue.dismiss()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .buttonStyle(FillButtonStyle())
    }

}
