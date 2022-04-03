import SwiftUI

struct ShopFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var address = ""
    @State private var image: UIImage?

    @EnvironmentObject var viewModel: VendorViewModel

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create your shop")
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

                viewModel.createShop(name: name,
                                     description: address,
                                     image: image)
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
