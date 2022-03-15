import SwiftUI

struct LoginScreen: View {

    @ObservedObject var router: MainViewRouter
    @ObservedObject var loginViewModel: LoginViewModel

    init(router: MainViewRouter) {
        self.router = router
        self.loginViewModel = LoginViewModel(router: router)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HeadlineSection(title: "Login")
                LoginFields(email: $loginViewModel.email,
                            password: $loginViewModel.password)
                LoginButton(handler: loginViewModel.login)
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
        }
    }
}

private struct LoginButton: View {

    var handler: () -> Void

    var body: some View {
        PSButton(title: "Log in") {
            handler()
        }
        .buttonStyle(FillButtonStyle())
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
