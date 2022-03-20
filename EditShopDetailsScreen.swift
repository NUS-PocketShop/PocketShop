import SwiftUI

struct EditShopDetailsScreen: View {

    @State var name = ""
    @State var address = ""
    @State var image: UIImage?

    @EnvironmentObject var viewModel: VendorViewModel

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
            }.buttonStyle(FillButtonStyle())
        }
        .padding()
    }
}

struct EditShopDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        EditShopDetailsScreen()
    }
}
