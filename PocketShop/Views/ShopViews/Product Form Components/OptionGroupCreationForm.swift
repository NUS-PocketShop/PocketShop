/* A pop-up sheet modal for creating option groups */

import SwiftUI

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
