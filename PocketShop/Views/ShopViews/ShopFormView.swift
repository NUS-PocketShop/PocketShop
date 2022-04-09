import SwiftUI

struct ShopFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var address = ""
    @State private var image: UIImage?
    @State private var categories = [String]()

    @EnvironmentObject var viewModel: VendorViewModel

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create your shop").font(.appTitle)

            ScrollView(.vertical) {
                ShopTextFields(name: $name, address: $address, categories: $categories)
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

        guard !address.isEmpty else {
            alertMessage = "Shop address cannot be empty!"
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
                    description: address,
                    locationId: "", // placeholder
                    imageURL: "",
                    isClosed: false,
                    ownerId: vendor.id,
                    soldProducts: [],
                    categories: shopCategories,
                    tags: []) // placeholder
    }
}

struct ShopTextFields: View {
    @Binding var name: String
    @Binding var address: String
    @Binding var categories: [String]

    var body: some View {
        PSTextField(text: $name,
                    title: "Shop Name",
                    placeholder: "Shop Name")

        PSTextField(text: $address,
                    title: "Shop Address",
                    placeholder: "Shop Address")

        ForEach(0..<categories.count, id: \.self) { index in
            PSTextField(text: $categories[index],
                        title: "Shop Category \(index + 1)",
                        placeholder: "Shop Category \(index + 1)")
        }

        Button(action: {
            categories.append("")
        }, label: {
            Text("\(Image(systemName: "plus.circle")) Add new shop category")
        })
        .padding(.vertical)
    }
}
