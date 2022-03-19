import SwiftUI

struct RegisterScreen: View {

    @ObservedObject var registerViewModel: RegisterViewModel

    init(router: MainViewRouter) {
        self.registerViewModel = RegisterViewModel(router: router)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HeadlineSection(title: "Register new account")
                RegisterFields(email: $registerViewModel.email,
                               password: $registerViewModel.password,
                               confirmPassword: $registerViewModel.confirmPassword,
                               errorMessage: $registerViewModel.errorMessage)
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
        RegisterScreen(router: MainViewRouter())
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
