import SwiftUI

struct URLImage: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image = UIImage()

    init(urlString: String) {
        self.imageLoader = ImageLoader(urlString: urlString)
    }

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .onReceive(imageLoader.didChange) { data in
                self.image = UIImage(data: data) ?? UIImage()
            }
    }
}
