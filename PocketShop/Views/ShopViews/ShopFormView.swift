import SwiftUI

struct ShopFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var location = ""
    @State private var description = ""
    @State private var image: UIImage?
    @State private var categories = [String]()

    @EnvironmentObject var viewModel: VendorViewModel

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create your shop").font(.appTitle)

            ScrollView(.vertical) {
                ShopTextFields(name: $name, location: $location, description: $description, categories: $categories)
                PSImagePicker(title: "Shop Image", image: $image)
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

                guard let shop = createNewShop() else {
                    print("Shop creation unsuccessful")
                    return
                }

                viewModel.createShop(shop: shop, image: image)
                presentationMode.wrappedValue.dismiss()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }.buttonStyle(FillButtonStyle())
        }
        .padding()
    }

    func createNewShop() -> Shop? {
        guard let vendor = viewModel.vendor else {
            print("Vendor not initialized!")
            return nil
        }

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

        return Shop(id: "",
                    name: name,
                    description: description,
                    locationId: viewModel.getLocationIdFromName(locationName: location),
                    imageURL: "",
                    isClosed: false,
                    ownerId: vendor.id,
                    soldProducts: [],
                    categories: shopCategories)
    }
}

struct ShopTextFields: View {
    @Binding var name: String
    @Binding var location: String
    @Binding var description: String
    @Binding var categories: [String]

    var body: some View {
        PSTextField(text: $name,
                    title: "Shop Name",
                    placeholder: "Shop Name")

        LocationPickerSection(location: $location)

        PSTextField(text: $description,
                    title: "Shop Description",
                    placeholder: "Shop Description")

        PSMultiLineTextField(groupTitle: "Shop Categories",
                             fieldTitle: "Shop Category",
                             fields: $categories)
    }
}

struct LocationPickerSection: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Binding var location: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Product Location".uppercased())
                    .font(.appSmallCaption)

                Picker("Select a product location", selection: $location) {
                    ForEach(viewModel.locations, id: \.self.name) { location in
                        Text(location.name)
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: Constants.maxWidthIPad)
    }
}
