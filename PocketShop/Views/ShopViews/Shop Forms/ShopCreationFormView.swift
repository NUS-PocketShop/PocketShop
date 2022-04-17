import SwiftUI

struct ShopCreationFormView: View {
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
                    print("FATAL ERROR: Shop creation unsuccessful")
                    return
                }
                viewModel.createShop(shop: shop, image: image)
                presentationMode.wrappedValue.dismiss()
            }.buttonStyle(FillButtonStyle())
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
        }
        .frame(maxWidth: Constants.maxWidthIPad)
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

        if let imageData = image?.pngData(), imageData.count > DBStorage.MAX_FILE_SIZE {
            alertMessage = "Uploaded image size must be less than 5MB"
            showAlert = true
            return nil
        }

        let uniqueCategories = Array(Set(categories.filter { !$0.isEmpty }))

        guard uniqueCategories.count == categories.count else {
            alertMessage = "Shop category cannot be blank or repeated!"
            showAlert = true
            return nil
        }

        guard !uniqueCategories.isEmpty else {
            alertMessage = "Shop must have at least 1 category!"
            showAlert = true
            return nil
        }

        let shopCategories = categories.enumerated().map { ShopCategory(title: $1, categoryOrderingIndex: $0) }

        return Shop(id: ID(strVal: "default"),
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
        VStack(alignment: .leading) {
            PSTextField(text: $name,
                        title: "Shop Name",
                        placeholder: "Shop Name")

            LocationPickerSection(location: $location)
                .padding(.vertical)

            PSTextField(text: $description,
                        title: "Shop Description",
                        placeholder: "Shop Description")

            PSMultiLineTextField(groupTitle: "Shop Categories",
                                 fieldTitle: "Shop Category",
                                 fields: $categories)
                .padding(.vertical)
        }
    }
}

struct LocationPickerSection: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Binding var location: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Shop Location".uppercased())
                    .font(.appSmallCaption)

                Picker("\(location.isEmpty ? "Select a shop location" : location)", selection: $location) {
                    ForEach(viewModel.locations, id: \.self.name) { location in
                        Text(location.name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            Spacer()
        }
        .frame(maxWidth: Constants.maxWidthIPad)
    }
}
