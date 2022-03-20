import SwiftUI

struct PSRadioButtonGroup: View {

    let title: String
    let options: [String]
    @State var selectedId: String = ""
    let callback: (String) -> Void

    var body: some View {
        HStack(spacing: 32) {
            RadioButtonGroupHeader(title: title)

            VStack {
                ForEach(options.indices) { i in
                    PSRadioButton(option: options[i],
                                  selectedId: selectedId,
                                  callback: self.radioGroupCallback)
                }
            }
            .padding()
        }.frame(maxWidth: Constants.maxWidthIPad)
    }

    func radioGroupCallback(toSelect: String) {
        selectedId = toSelect
        callback(toSelect)
    }
}

struct PSRadioButton: View {
    typealias selectionHandler = (String) -> Void

    var option: String
    var selectedId: String
    private var isSelected: Bool {
        option == selectedId
    }
    let callback: (String) -> Void

    var body: some View {
        Button {
            callback(option)
        } label: {
            HStack {
                Circle()
                    .stroke(self.isSelected ? Color.accent : Color.gray6,
                            lineWidth: 2)
                    .overlay(
                        Circle().fill(self.isSelected ? Color.accent : .clear)
                            .frame(width: 10.0, height: 10.0)
                    )
                    .frame(width: 20.0, height: 20.0)

                Text(option)
                    .font(.appButton)
            }
        }
        .border(self.isSelected ? Color.accent : Color.gray6, width: 1)
        .background(self.isSelected ? Color.white : Color.gray3)
        .buttonStyle(SecondaryButtonStyle())
    }

}

struct RadioButtonGroupHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.appCaption)
    }
}
