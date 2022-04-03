import SwiftUI

struct ShopEditFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var address = ""
    @State private var image: UIImage?

    @EnvironmentObject var viewModel: VendorViewModel
    var shop: Shop

    @State private var showAlert = false
    @State private var alertMessage = ""

    init(viewModel: VendorViewModel, shop: Shop) {
        self.shop = shop
        self._name = State(initialValue: shop.name)
        self._address = State(initialValue: shop.description)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edit your shop")
                .font(.appTitle)

            ScrollView(.vertical) {
                PSTextField(text: $name,
                            title: "Shop Name",
                            placeholder: "Shop Name")

                PSTextField(text: $address,
                            title: "Shop Address",
                            placeholder: "Shop Address")

                PSImagePicker(title: "Shop Image",
                              image: $image)
                    .onAppear {
                        DatabaseManager.sharedDatabaseManager.getShopImage(shopId: shop.id,
                                                                           completionHandler: { error, imgData in
                            guard let imgData = imgData, error == nil else {
                                return
                            }
                            image = UIImage(data: imgData)
                        })
                    }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })

            Spacer()

            PSButton(title: "Confirm") {
                guard !name.isEmpty else {
                    alertMessage = "Shop name cannot be empty!"
                    showAlert = true
                    return
                }

                guard !address.isEmpty else {
                    alertMessage = "Shop address cannot be empty!"
                    showAlert = true
                    return
                }

                guard let image = image else {
                    alertMessage = "Missing product image!"
                    showAlert = true
                    return
                }

                let newShop = Shop(id: shop.id,
                                   name: name,
                                   description: address,
                                   imageURL: "",
                                   isClosed: shop.isClosed,
                                   ownerId: shop.ownerId,
                                   soldProducts: shop.soldProducts,
                                   categories: shop.categories)

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
}
