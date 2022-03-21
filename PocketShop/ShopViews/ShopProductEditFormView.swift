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
        self.name = product.name
        self.price = String(product.price)
        self.description = product.description
        self.prepTime = String(product.estimatedPrepTime)
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
                    .padding(.bottom)

                PSButton(title: "Save") {
                    guard let image = image, !name.isEmpty,
                          let price = Double(price),
                          let estimatedPrepTime = Double(prepTime) else {
                        return
                    }
                    // Create Product and save to db
                    viewModel.editProduct(oldProductId: product.id,
                                          name: name,
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
