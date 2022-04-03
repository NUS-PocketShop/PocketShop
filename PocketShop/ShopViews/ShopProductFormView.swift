import SwiftUI

struct ShopProductFormView: View {
    @StateObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var price = ""
    @State private var prepTime = ""
    @State private var description = ""
    @State private var image: UIImage?
    @State private var category = ""

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add new product")
                    .font(.appTitle)

                UserInputSegment(name: $name,
                                 price: $price,
                                 description: $description,
                                 prepTime: $prepTime,
                                 category: $category)

                PSImagePicker(title: "Product Image", image: $image)
                    .padding(.bottom)

                SaveNewProductButton(viewModel: viewModel, name: $name, price: $price,
                                     prepTime: $prepTime, description: $description,
                                     image: $image, category: $category)
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
    @Binding var category: String

    var body: some View {
        VStack {
            PSTextField(text: $name,
                        title: "Product Name",
                        placeholder: "Enter product name")

            PSTextField(text: $price,
                        title: "Product Price",
                        placeholder: "Enter product price")
                .keyboardType(.numberPad)

            PSTextField(text: $description,
                        title: "Product Description (optional)",
                        placeholder: "Enter product description")

            PSTextField(text: $category,
                        title: "Product Category (optional)",
                        placeholder: "Enter product category")

            PSTextField(text: $prepTime,
                        title: "Estimated Prep Time",
                        placeholder: "Enter estimated prep time")
                .keyboardType(.numberPad)
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
    @Binding var category: String

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        PSButton(title: "Save") {
            guard !name.isEmpty else {
                alertMessage = "Product name cannot be empty!"
                showAlert = true
                return
            }

            guard let inputPrice = Double(price) else {
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
            viewModel.createProduct(name: name, description: description, price: inputPrice,
                                    estimatedPrepTime: estimatedPrepTime, image: image, category: category)

            presentationMode.wrappedValue.dismiss()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .buttonStyle(FillButtonStyle())
    }

}
