import SwiftUI

struct ShopProductEditFormView: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode
    var product: Product

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var description: String = ""
    @State private var prepTime: String = ""
    @State private var image: UIImage?
    @State private var category: String = ""
    @State private var isCombo = false
    @State private var comboComponents = [String]()
    @State private var options = [ProductOption]()
    @State private var tags = [String]()

    init(viewModel: VendorViewModel, product: Product) {
        self.product = product
        self._name = State(initialValue: product.name)
        self._price = State(initialValue: String(product.price))
        self._description = State(initialValue: product.description)
        self._prepTime = State(initialValue: String(product.estimatedPrepTime))
        self._category = State(initialValue: product.shopCategory?.title ?? "")
        self._isCombo = State(initialValue: product.isComboMeal)
        self._options = State(initialValue: product.options)
        self._tags = State(initialValue: product.tags.map { $0.tag })
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit product")
                    .font(.appTitle)

                UserInputSegment(name: $name, price: $price, description: $description,
                                 prepTime: $prepTime, category: $category, options: $options,
                                 isCombo: $isCombo, comboComponents: $comboComponents, tags: $tags)

                PSImagePicker(title: "Product Image",
                              image: $image)
                    .onAppear {
                        DatabaseManager.sharedDatabaseManager.getProductImage(productId: product.id,
                                                                              completionHandler: { error, imgData in
                            guard let imgData = imgData, error == nil else {
                                return
                            }
                            image = UIImage(data: imgData)
                        })
                    }
                    .padding(.bottom)

                SaveEditedProductButton(product: product,
                                        name: $name, price: $price, description: $description, prepTime: $prepTime,
                                        image: $image, category: $category, options: $options, tags: $tags)
            }
            .padding()
        }
        .navigationBarItems(trailing: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

struct SaveEditedProductButton: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode
    var product: Product

    @Binding var name: String
    @Binding var price: String
    @Binding var description: String
    @Binding var prepTime: String
    @Binding var image: UIImage?
    @Binding var category: String
    @Binding var options: [ProductOption]
    @Binding var tags: [String]

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        PSButton(title: "Save") {
            guard let image = image else {
                alertMessage = "Missing product image!"
                showAlert = true
                return
            }

            guard let newProduct = createEditedProduct() else {
                print("Product edit unsuccessful")
                return
            }

            viewModel.editProduct(newProduct: newProduct, image: image)
            presentationMode.wrappedValue.dismiss()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .buttonStyle(FillButtonStyle())
    }

    func createEditedProduct() -> Product? {
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

        if let imageData = image?.pngData(), imageData.count > DBStorage.MAX_FILE_SIZE {
            alertMessage = "Uploaded image size must be less than 5MB"
            showAlert = true
            return nil
        }

        let uniqueTags = Array(Set(tags.filter { !$0.isEmpty })).map { ProductTag(tag: $0) }

        // Create edited Product and save to db
        return Product(id: product.id,
                       name: name,
                       description: description,
                       price: inputPrice,
                       imageURL: "",
                       estimatedPrepTime: estimatedPrepTime,
                       isOutOfStock: false,
                       options: options,
                       tags: uniqueTags,
                       shopId: product.shopId,
                       shopName: product.shopName,
                       shopCategory: ShopCategory(title: category),
                       subProductIds: [])
    }
}
