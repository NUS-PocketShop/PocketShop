import SwiftUI

struct ShopProductFormView: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var price = ""
    @State private var prepTime = ""
    @State private var description = ""
    @State private var image: UIImage?
    @State private var category = ""
    @State private var comboComponents = [String]()
    @State private var isCombo = true
    @State private var options = [ProductOption]()
    @State private var tags = [String]()

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add new \(isCombo ? "Combo" : "Product")")
                    .font(.appTitle)

                UserInputSegment(name: $name,
                                 price: $price,
                                 description: $description,
                                 prepTime: $prepTime,
                                 category: $category,
                                 options: $options,
                                 isCombo: $isCombo,
                                 comboComponents: $comboComponents)
                                 tags: $tags)

                PSImagePicker(title: "\(isCombo ? "Combo" : "Product") Image", image: $image)
                    .padding(.bottom)

                SaveNewProductButton(name: $name, price: $price,
                                     prepTime: $prepTime, description: $description,
                                     image: $image, category: $category,
                                     options: $options, tags: $tags)
            }.padding()
        }
        .navigationBarItems(trailing: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

struct UserInputSegment: View {
    @EnvironmentObject var viewModel: VendorViewModel

    @Binding var name: String
    @Binding var price: String
    @Binding var description: String
    @Binding var prepTime: String
    @Binding var category: String
    @Binding var options: [ProductOption]
    @Binding var isCombo: Bool
    @Binding var comboComponents: [String]
    @Binding var tags: [String]

    private var productType: String {
        isCombo ? "Combo" : "Product"
    }

    var body: some View {
        VStack {
            Toggle("Creating a Combo", isOn: $isCombo)
                .font(.appCaption)
                .padding()
                .frame(maxWidth: Constants.maxWidthIPad)

            BasicProductInfoSection(name: $name,
                                    price: $price,
                                    description: $description,
                                    prepTime: $prepTime,
                                    productType: productType)

            CategoryPickerSection(category: $category,
                                  title: "Select \(productType) Category")

            if isCombo {
                ComboBuilderSection()
            }

            OptionGroupSection(options: $options,
                               productType: productType)

            PSMultiLineTextField(groupTitle: "Product Tags (Optional)",
                                 fieldTitle: "Product Tag",
                                 fields: $tags)
        }
    }
}

private struct SaveNewProductButton: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode

    @Binding var name: String
    @Binding var price: String
    @Binding var prepTime: String
    @Binding var description: String
    @Binding var image: UIImage?
    @Binding var category: String
    @Binding var options: [ProductOption]
    @Binding var tags: [String]

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        PSButton(title: "Save") {
            guard let image = image else {
                alertMessage = "Missing product image!"
                showAlert = true
                return
            }

            guard let product = createNewProduct() else {
                print("Product creation unsuccessful")
                return
            }

            // Create Product and save to db
            viewModel.createProduct(product: product, image: image)
            presentationMode.wrappedValue.dismiss()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .buttonStyle(FillButtonStyle())
    }

    func createNewProduct() -> Product? {
        guard let shop = viewModel.currentShop else {
            print("No current shop!")
            return nil
        }

        guard !name.isEmpty else {
            alertMessage = "Product name cannot be empty!"
            showAlert = true
            return nil
        }

        guard let inputPrice = Double(price) else {
            alertMessage = price.isEmpty ? "Product price can't be empty!" : "Product price must be a valid double!"
            showAlert = true
            return nil
        }

        guard let estimatedPrepTime = Double(prepTime) else {
            alertMessage = prepTime.isEmpty ? "Product prep time can't be empty!"
                                            : "Product prep time must be a valid double!"
            showAlert = true
            return nil
        }

        guard !category.isEmpty else {
            alertMessage = "Please select a category from the dropdown menu or add a new category to your shop"
            showAlert = true
            return nil
        }

        let uniqueTags = Array(Set(tags.filter { !$0.isEmpty })).map { ProductTag(tag: $0) }

        return Product(id: ID(strVal: "default"),
                       name: name,
                       description: description,
                       price: inputPrice,
                       imageURL: "",
                       estimatedPrepTime: estimatedPrepTime,
                       isOutOfStock: false,
                       options: options,
                       tags: uniqueTags,
                       shopId: shop.id,
                       shopName: shop.name,
                       shopCategory: ShopCategory(title: category),
                       subProductIds: [])
    }
}

// MARK: Form Element #1 (Basic info)
private struct BasicProductInfoSection: View {
    @Binding var name: String
    @Binding var price: String
    @Binding var description: String
    @Binding var prepTime: String
    var productType: String

    var body: some View {
        VStack {
            PSTextField(text: $name,
                        title: "\(productType) Name",
                        placeholder: "Enter a name")

            PSTextField(text: $price,
                        title: "\(productType) Price",
                        placeholder: "Enter a price")
                .keyboardType(.numberPad)

            PSTextField(text: $description,
                        title: "\(productType) Description (optional)",
                        placeholder: "Enter a description")

            PSTextField(text: $prepTime,
                        title: "Estimated Prep Time",
                        placeholder: "Enter estimated prep time")
                .keyboardType(.numberPad)
        }
    }
}

// MARK: Form Element #2 (Category Selection)
struct CategoryPickerSection: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Binding var category: String

    var title: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(title)".uppercased())
                    .font(.appSmallCaption)

                Picker("\(category.isEmpty ? "Tap to Select" : category)", selection: $category) {
                    if let shop = viewModel.currentShop {
                        ForEach(shop.categories, id: \.self.title) { shopCategory in
                            Text(shopCategory.title)
                        }
                    }
                }
                .padding(.vertical)
                .pickerStyle(MenuPickerStyle())
            }
            Spacer()
        }
        .frame(maxWidth: Constants.maxWidthIPad)
    }
}

// MARK: Form Element #3 (Option Group Section)
private struct OptionGroupSection: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Binding var options: [ProductOption]

    var productType: String

    @State var isOptionGroupModalShown = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(productType) Options".uppercased())
                    .font(.appSmallCaption)

                ForEach(options, id: \.self) { optionGroup in
                    OptionGroupView(optionGroup: optionGroup)
                }

                PSButton(title: "Add Option Group") {
                    isOptionGroupModalShown = true
                }.buttonStyle(OutlineButtonStyle())
            }
            Spacer()
        }
        .frame(maxWidth: Constants.maxWidthIPad)
        .sheet(isPresented: $isOptionGroupModalShown) {
            OptionGroupCreationForm(options: $options)
        }
    }
}

private struct OptionGroupView: View {
    @State var optionGroup: ProductOption

    var body: some View {
        VStack(alignment: .leading) {
            Text(optionGroup.title)
                .font(.appHeadline)
            ForEach(optionGroup.optionChoices, id: \.self) { choice in
                HStack {
                    Text("\(choice.description)")
                        .font(.appBody)
                    Spacer()
                    Text("$\(choice.cost, specifier: "%.2f")")
                        .font(.appCaption)
                }
            }
        }
        .padding()
    }
}

// MARK: Form Element #4 (Option Group Section)
private struct ComboBuilderSection: View {
    @EnvironmentObject var viewModel: VendorViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Combo Products".uppercased())
                .font(.appSmallCaption)

            if let shop = viewModel.currentShop {
                List {
                    ForEach(shop.soldProducts.filter({ !$0.isComboMeal }), id: \.self.id) { product in
                        Text("\(product.name)")
                        /// The idea is to make a Multiple Selection List, as seen in
                        /// https://stackoverflow.com/questions/57022615/
                    }
                }
                Text("Number of products that are not combos: \(shop.soldProducts.filter({ !$0.isComboMeal }).count)")

                Button("Debug") {
                    shop.soldProducts.filter { !$0.isComboMeal }.map({ product in
                        print("pr name: \(product.name)")
                    })
                }.buttonStyle(OutlineButtonStyle())
            }
        }
        .frame(maxWidth: Constants.maxWidthIPad)
    }
}
