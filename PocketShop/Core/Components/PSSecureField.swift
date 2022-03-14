import SwiftUI

struct PSSecureField: View {

    @Binding var text: String
    var title: String = ""
    var icon: String = ""
    var placeholder: String = ""
    var keyboardType = UIKeyboardType.default

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title.uppercased())
                    .font(.appSmallCaption)
            }
            HStack {
                if !icon.isEmpty {
                    Image(systemName: icon)
                    .padding()
                }
                SecureField(placeholder, text: $text)
                    .font(.appCaption)
                    .foregroundColor(.gray9)
                    .padding()
            }
            .foregroundColor(.gray3)
            .background(Color.gray1)
        }
        .frame(maxWidth: Constants.maxWidthIPad)
    }
}
