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
    @State private var options = [ProductOption]()

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add new product")
                    .font(.appTitle)

                UserInputSegment(name: $name,
                                 price: $price,
                                 description: $description,
                                 prepTime: $prepTime,
                                 category: $category,
                                 options: $options)

                PSImagePicker(title: "Product Image", image: $image)
                    .padding(.bottom)

                SaveNewProductButton(name: $name, price: $price,
                                     prepTime: $prepTime, description: $description,
                                     image: $image, category: $category,
                                     options: $options)
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

    var body: some View {
        VStack {
            PSTextField(text: $name,
                        title: "Product Name",
                        placeholder: "Enter product name")

            PSTextField(text: $price,
                        title: "Product Price",
                        placeholder: "Enter product price")
                .keyboardType(.numberPad)

            PSTextField(text: $description,
                        title: "Product Description (optional)",
                        placeholder: "Enter product description")

            CategoryPickerSection(category: $category)

            PSTextField(text: $prepTime,
                        title: "Estimated Prep Time",
                        placeholder: "Enter estimated prep time")
                .keyboardType(.numberPad)

            OptionGroupSection(options: $options)
        }
    }
}

struct SaveNewProductButton: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Environment(\.presentationMode) var presentationMode

    @Binding var name: String
    @Binding var price: String
    @Binding var prepTime: String
    @Binding var description: String
    @Binding var image: UIImage?
    @Binding var category: String
    @Binding var options: [ProductOption]

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

        return Product(id: ID(strVal: "default"),
                       name: name,
                       description: description,
                       price: inputPrice,
                       imageURL: "",
                       estimatedPrepTime: estimatedPrepTime,
                       isOutOfStock: false,
                       options: options,
                       tags: [],
                       shopId: shop.id,
                       shopName: shop.name,
                       shopCategory: ShopCategory(title: category),
                       subProductIds: [])
    }

}

struct CategoryPickerSection: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Binding var category: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Select Product Category".uppercased())
                    .font(.appSmallCaption)

                Picker("Select a product category", selection: $category) {
                    if let shop = viewModel.currentShop {
                        ForEach(shop.categories, id: \.self.title) { shopCategory in
                            Text(shopCategory.title)
                        }
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: Constants.maxWidthIPad)
    }
}

struct OptionGroupSection: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @Binding var options: [ProductOption]

    @State var isOptionGroupModalShown = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Product Options".uppercased())
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

struct OptionGroupCreationForm: View {
    @Environment(\.presentationMode) var presentationMode

    @State var title: String = ""
    @Binding var options: [ProductOption]
    @State var userOptions = [String]()
    @State var userPrices = [String]()

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create option group")
                .font(.appTitle)

            PSTextField(text: $title,
                        title: "Option Group Title",
                        placeholder: "Enter option group title")

            OptionFields(userOptions: $userOptions, userPrices: $userPrices)

            Button(action: {
                userOptions.append("")
                userPrices.append("")
            }, label: {
                Text("\(Image(systemName: "plus.circle")) Add option")
            })
            .padding(.vertical)

            Spacer()

            SaveOptionGroupButton(title: $title, options: $options, userOptions: $userOptions,
                                  userPrices: $userPrices, showAlert: $showAlert, alertMessage: $alertMessage)

            PSButton(title: "Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.buttonStyle(OutlineButtonStyle())
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .padding()
        .frame(maxWidth: Constants.maxWidthIPad)
    }
}

struct OptionFields: View {
    @Binding var userOptions: [String]
    @Binding var userPrices: [String]

    var body: some View {
        ForEach(0..<userOptions.count, id: \.self) { index in
            HStack {
                PSTextField(text: $userOptions[index],
                            title: "Option \(index + 1)",
                            placeholder: "Enter option name")
                PSTextField(text: $userPrices[index],
                            title: "Price",
                            placeholder: "Enter option price")
                    .keyboardType(.numberPad)
            }
        }
    }
}

struct SaveOptionGroupButton: View {
    @Environment(\.presentationMode) var presentationMode

    @Binding var title: String
    @Binding var options: [ProductOption]
    @Binding var userOptions: [String]
    @Binding var userPrices: [String]

    @Binding var showAlert: Bool
    @Binding var alertMessage: String

    var body: some View {
        PSButton(title: "Save") {
            guard !title.isEmpty else {
                alertMessage = "Please enter a title for option group!"
                showAlert = true
                return
            }
            guard !userOptions.allSatisfy({ $0.isEmpty }),
                  !userPrices.allSatisfy({ $0.isEmpty }) else {
                alertMessage = "Please enter all options/prices"
                showAlert = true
                return
            }
            options.append(createOptionGroupFrom(title: title,
                                                 userOptions: userOptions,
                                                 userPrices: userPrices))
            presentationMode.wrappedValue.dismiss()
        }.buttonStyle(FillButtonStyle())
    }

    func createOptionGroupFrom(title: String, userOptions: [String], userPrices: [String]) -> ProductOption {
        var choices = [ProductOptionChoice]()
        for i in 0..<userOptions.count {
            choices.append(ProductOptionChoice(description: userOptions[i],
                                               cost: Double(userPrices[i]) ?? 0))
        }
        let option = ProductOption(title: title,
                                   type: .selectOne,
                                   optionChoices: choices)
        return option
    }
}

struct OptionGroupView: View {

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
