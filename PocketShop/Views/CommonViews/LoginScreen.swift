import SwiftUI

struct LoginScreen: View {

    @EnvironmentObject var router: MainViewRouter
    @ObservedObject var loginViewModel: LoginViewModel

    init(router: MainViewRouter) {
        self.loginViewModel = LoginViewModel(router: router)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HeadlineSection(title: "Login")
                LoginFields(email: $loginViewModel.email,
                            password: $loginViewModel.password,
                            errorMessage: $loginViewModel.errorMessage)
                LoginButton(handler: loginViewModel.login,
                            isLoading: $loginViewModel.isLoading)
                SignUpSection(router: router)
            }
            .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen(router: MainViewRouter())

    }
}

// MARK: SubViews
private struct LoginFields: View {
    @Binding var email: String
    @Binding var password: String
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
                          placeholder: "Password",
                          errorMessage: errorMessage)
        }
    }
}

private struct LoginButton: View {

    var handler: () -> Void
    @Binding var isLoading: Bool

    var body: some View {
        if isLoading {
            ProgressView()
        } else {
            PSButton(title: "Log in") {
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

private struct SignUpSection: View {

    var router: MainViewRouter

    var body: some View {
        HStack {
            Text("Don't have an account?")
            NavigationLink(
                destination: RegisterScreen(router: router),
                label: {
                    Text("Sign Up")
                })
        }
        .font(.appBody)
    }
}
