import SwiftUI

struct PSMultiLineTextField: View {
    var groupTitle: String
    var fieldTitle: String
    @Binding var fields: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(groupTitle.uppercased())
                .font(.appSmallCaption)

            ForEach(0..<fields.count, id: \.self) { index in
                HStack {
                    PSTextField(text: Binding(get: { fields[index] },
                                              set: { fields[index] = $0 }),
                                title: "\(fieldTitle) \(index + 1)",
                                placeholder: "\(fieldTitle) \(index + 1)")

                    Button(action: {
                        fields.remove(at: index)
                    }, label: {
                        Image(systemName: "minus.circle")
                            .foregroundColor(Color.red7)
                    }).padding(.top)
                }
            }

            Button(action: {
                fields.append("")
            }, label: {
                Text("\(Image(systemName: "plus.circle")) Add new \(fieldTitle.lowercased())")
            })
        }
    }
}
