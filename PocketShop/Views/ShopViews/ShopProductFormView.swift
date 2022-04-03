import SwiftUI

struct ShopProductFormView: View {
    @EnvironmentObject var viewModel: VendorViewModel
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

                SaveNewProductButton(name: $name, price: $price,
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
    @EnvironmentObject var viewModel: VendorViewModel

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

            CategoryPickerSection(category: $category)

            PSTextField(text: $prepTime,
                        title: "Estimated Prep Time",
                        placeholder: "Enter estimated prep time")
                .keyboardType(.numberPad)
        }
    }
}

struct SaveNewProductButton: View {
    @EnvironmentObject var viewModel: VendorViewModel
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
            guard let image = image else {
                alertMessage = "Missing product image!"
                showAlert = true
                return
            }

            guard let product = createNewProduct() else {
                print("Product creation unsuccessful")
                return
            }

            // Create Product and save to db
            viewModel.createProduct(product: product, image: image)
            presentationMode.wrappedValue.dismiss()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .buttonStyle(FillButtonStyle())
    }

    func createNewProduct() -> Product? {
        guard let shop = viewModel.currentShop else {
            print("No current shop!")
            return nil
        }

        guard !name.isEmpty else {
            alertMessage = "Product name cannot be empty!"
            showAlert = true
            return nil
        }

        guard let inputPrice = Double(price) else {
            alertMessage = price.isEmpty ? "Product price can't be empty!" : "Product price must be a valid double!"
            showAlert = true
            return nil
        }

        guard let estimatedPrepTime = Double(prepTime) else {
            alertMessage = prepTime.isEmpty ? "Product prep time can't be empty!"
                                            : "Product prep time must be a valid double!"
            showAlert = true
            return nil
        }

        guard !category.isEmpty else {
            alertMessage = "Please select a category from the dropdown menu or add a new category to your shop"
            showAlert = true
            return nil
        }

        return Product(id: "",
                       name: name,
                       shopName: shop.name,
                       shopId: shop.id,
                       description: description,
                       price: inputPrice,
                       imageURL: "",
                       estimatedPrepTime: estimatedPrepTime,
                       isOutOfStock: false,
                       shopCategory: ShopCategory(title: category),
                       options: [])
    }

}

struct CategoryPickerSection: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Binding var category: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Select Product Category".uppercased())
                    .font(.appSmallCaption)

                Picker("Select a product category", selection: $category) {
                    if let shop = viewModel.currentShop {
                        ForEach(shop.categories, id: \.self.title) { shopCategory in
                            Text(shopCategory.title)
                        }
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: Constants.maxWidthIPad)
    }
}
