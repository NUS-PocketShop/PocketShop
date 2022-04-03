import SwiftUI

struct PSImagePicker: View {

    var title: String = ""
    @State var showImagePicker = false
    @Binding var image: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.appSmallCaption)

            if let image = image {
                Image(uiImage: image).resizable().scaledToFit()
                    .frame(height: 150)
            } else {
                Image(systemName: "photo").resizable().scaledToFit().padding().foregroundColor(Color.gray3)
                    .frame(height: 150)
            }

            PSButton(title: "Choose Image") {
                showImagePicker = true
            }.buttonStyle(OutlineButtonStyle())
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerWrapperView(showImagePicker: $showImagePicker,
                                   image: $image)
        }

        .frame(maxWidth: Constants.maxWidthIPad)
    }
}

// from https://betterprogramming.pub/implement-imagepicker-using-swiftui-7f2a28caaf9c

struct ImagePickerWrapperView: View {

    @Binding var showImagePicker: Bool
    @Binding var image: UIImage?

    var body: some View {
        ImagePicker(isShown: $showImagePicker, image: $image)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isShown: Bool
    @Binding var image: UIImage?

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    func makeCoordinator() -> ImagePickerCordinator {
        ImagePickerCordinator(isShown: $isShown, image: $image)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
}

class ImagePickerCordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var isShown: Bool
    @Binding var image: UIImage?

    init(isShown: Binding<Bool>, image: Binding<UIImage?>) {
        _isShown = isShown
        _image = image
    }

    // Selected Image
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        image = uiImage
        isShown = false
    }

    // Image selection got cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
    }
}
