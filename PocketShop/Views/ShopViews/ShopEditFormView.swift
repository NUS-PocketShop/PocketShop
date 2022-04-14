import SwiftUI

struct ShopEditFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var location = ""
    @State private var description = ""
    @State private var image: UIImage?
    @State private var categories = [String]()

    @EnvironmentObject var viewModel: VendorViewModel
    var shop: Shop

    @State private var showAlert = false
    @State private var alertMessage = ""

    init(viewModel: VendorViewModel, shop: Shop) {
        self.shop = shop
        self._name = State(initialValue: shop.name)
        self._location = State(initialValue: shop.description)
        self._description = State(initialValue: shop.description)
        self._categories = State(initialValue: shop.categories.map { $0.title })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edit your shop").font(.appTitle)

            ScrollView(.vertical) {
                ShopTextFields(name: $name, location: $location, description: $description, categories: $categories)

                PSImagePicker(title: "Shop Image", image: $image).onAppear { loadImage() }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })

            Spacer()

            PSButton(title: "Confirm") {
                guard let image = image else {
                    alertMessage = "Missing product image!"
                    showAlert = true
                    return
                }

                guard let newShop = createEditedShop() else {
                    print("Shop edit unsuccessful")
                    return
                }

                viewModel.editShop(newShop: newShop, image: image)
                presentationMode.wrappedValue.dismiss()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
            .buttonStyle(FillButtonStyle())
        }
        .padding()
    }

    private func loadImage() {
        DatabaseManager.sharedDatabaseManager.getShopImage(shopId: shop.id,
                                                           completionHandler: { error, imgData in
            guard let imgData = imgData, error == nil else {
                return
            }
            image = UIImage(data: imgData)
        })
    }

    private func createEditedShop() -> Shop? {
        guard !name.isEmpty else {
            alertMessage = "Shop name cannot be empty!"
            showAlert = true
            return nil
        }

        guard !description.isEmpty else {
            alertMessage = "Shop description cannot be empty!"
            showAlert = true
            return nil
        }

        guard !location.isEmpty else {
            alertMessage = "Shop location cannot be empty!"
            showAlert = true
            return nil
        }

        let uniqueCategories = Array(Set(categories.filter { !$0.isEmpty }))

        guard !uniqueCategories.isEmpty else {
            alertMessage = "Shop must have at least 1 category!"
            showAlert = true
            return nil
        }

        let shopCategories = uniqueCategories.map { ShopCategory(title: $0) }

        return Shop(id: shop.id,
                    name: name,
                    description: description,
                    locationId: viewModel.getLocationIdFromName(locationName: location),
                    imageURL: "",
                    isClosed: shop.isClosed,
                    ownerId: shop.ownerId,
                    soldProducts: shop.soldProducts,
                    categories: shopCategories)
    }
}
