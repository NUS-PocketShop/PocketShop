import SwiftUI

struct RegisterScreen: View {

    @EnvironmentObject var registerViewModel: RegisterViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HeadlineSection(title: "Register new account")
                ScrollView(.vertical) {
                    RegisterFields(email: $registerViewModel.email,
                                   password: $registerViewModel.password,
                                   confirmPassword: $registerViewModel.confirmPassword,
                                   errorMessage: $registerViewModel.errorMessage)
                    PSRadioButtonGroup(title: "I am a",
                                       options: ["Customer", "Vendor"],
                                       selectedId: registerViewModel.accountType?.rawValue ?? 0,
                                       callback: { option in
                                        registerViewModel.setAccountType(option)
                                     })
                }

                RegisterButton(handler: registerViewModel.register,
                               isLoading: $registerViewModel.isLoading)
            }
            .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RegisterScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterScreen()
    }
}

// MARK: SubViews
private struct RegisterFields: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var errorMessage: String

    var body: some View {
        VStack {
            PSTextField(text: $email,
                        title: "Email",
                        icon: "envelope",
                        placeholder: "Email")
                .keyboardType(.emailAddress)
            PSSecureField(text: $password,
                          title: "Password",
                          icon: "key",
                          placeholder: "Password")
            PSSecureField(text: $confirmPassword,
                          title: "Re enter password",
                          icon: "key",
                          placeholder: "Re enter password",
                          errorMessage: errorMessage)
        }
    }
}

private struct RegisterButton: View {
    var handler: () -> Void
    @Binding var isLoading: Bool

    var body: some View {

        if isLoading {
            ProgressView()
        } else {
            PSButton(title: "Register") {
                withAnimation {
                    handler()
                }
            }
            .buttonStyle(FillButtonStyle())
        }
    }
}

private struct HeadlineSection: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.appTitle)
    }
}
