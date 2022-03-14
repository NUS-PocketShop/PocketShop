import SwiftUI

struct PSButton: View {

    typealias actionHandler = () -> Void

    let action: actionHandler
    let title: String
    let icon: String
    let iconOnRight: Bool

    internal init(title: String = "",
                  icon: String = "",
                  iconOnRight: Bool = false,
                  action: @escaping PSButton.actionHandler) {
        self.title = title
        self.icon = icon
        self.iconOnRight = iconOnRight
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                if !icon.isEmpty && !iconOnRight {
                    Image(systemName: icon)
                }

                if !title.isEmpty {
                    Text(title)
                        .font(.appButton)
                }

                if !icon.isEmpty && iconOnRight {
                    Image(systemName: icon)
                }
            }
        }
    }
}

struct FillButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: Constants.maxWidthIPad)
            .padding()
            .background(Color.accent)
            .foregroundColor(Color.white)
            .cornerRadius(4.0)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.2))
    }
}

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: Constants.maxWidthIPad)
            .padding()
            .foregroundColor(Color.accent)
            .background(Color.white)
            .cornerRadius(4.0)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.2))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: Constants.maxWidthIPad)
            .padding()
            .background(Color.white)
            .foregroundColor(Color.black)
            .cornerRadius(4.0)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.2))
    }
}

struct TrailingTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: Constants.maxWidthIPad, alignment: .trailing)
            .padding()
            .foregroundColor(Color.accent)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.2))
    }
}

struct LeadingTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: Constants.maxWidthIPad, alignment: .leading)
            .padding()
            .foregroundColor(Color.accent)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.2))
    }
}
