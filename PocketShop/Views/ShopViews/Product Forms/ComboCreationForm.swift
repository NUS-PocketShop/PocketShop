import SwiftUI

struct ComboCreationForm: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: VendorViewModel
    @Binding var selectedProducts: Set<Product>

    var selectableProducts: [Product]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select products for combo")
                    .font(.appTitle)

                List(selectableProducts, id: \.self, selection: $selectedProducts) { product in
                    ProductListView(product: product)
                }
                Spacer()
                PSButton(title: "Confirm") {
                    presentationMode.wrappedValue.dismiss()
                }.buttonStyle(FillButtonStyle())
            }
            .navigationBarHidden(true)
            .environment(\.editMode, .constant(EditMode.active))
            .frame(maxWidth: Constants.maxWidthIPad)
            .padding()
        }
    }
}
