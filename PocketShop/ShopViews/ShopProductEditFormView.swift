import SwiftUI

struct ShopProductEditFormView: View {
    @StateObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode
    var product: Product

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var description: String = ""
    @State private var prepTime: String = ""
    @State private var image: UIImage?

    init(viewModel: VendorViewModel, product: Product) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.product = product
        self._name = State(initialValue: product.name)
        self._price = State(initialValue: String(product.price))
        self._description = State(initialValue: product.description)
        self._prepTime = State(initialValue: String(product.estimatedPrepTime))
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit product")
                    .font(.appTitle)

                UserInputSegment(name: $name,
                                 price: $price,
                                 description: $description,
                                 prepTime: $prepTime)

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

                SaveEditedProductButton(viewModel: viewModel, product: product,
                                        name: $name, price: $price, description: $description,
                                        prepTime: $prepTime, image: $image)
            }
            .padding()
        }
        .navigationBarItems(trailing: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

struct SaveEditedProductButton: View {
    @StateObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode
    var product: Product

    @Binding var name: String
    @Binding var price: String
    @Binding var description: String
    @Binding var prepTime: String
    @Binding var image: UIImage?

    var body: some View {
        PSButton(title: "Save") {
            guard let image = image, !name.isEmpty,
                  let price = Double(price),
                  let estimatedPrepTime = Double(prepTime) else {
                return
            }
            // Create edited Product and save to db
            let product = Product(id: product.id,
                                  name: name,
                                  shopName: product.shopName,
                                  shopId: product.shopId,
                                  description: description,
                                  price: price,
                                  imageURL: "",
                                  estimatedPrepTime: estimatedPrepTime,
                                  isOutOfStock: false,
                                  options: [])

            viewModel.editProduct(newProduct: product, image: image)
            presentationMode.wrappedValue.dismiss()

        }
        .buttonStyle(FillButtonStyle())
    }
}
