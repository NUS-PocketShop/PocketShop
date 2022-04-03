import SwiftUI

struct ShopFormView: View {

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
            Spacer()
            PSButton(title: "Confirm") {
                guard let image = image else {
                    // error: please select an image
                    return
                }
                viewModel.createShop(name: name,
                                     description: address,
                                     image: image)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
            .buttonStyle(FillButtonStyle())
        }
        .padding()
    }
}
