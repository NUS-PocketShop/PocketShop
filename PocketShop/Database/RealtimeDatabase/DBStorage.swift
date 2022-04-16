import Firebase

class DBStorage {
    let imageRef = FirebaseManager.sharedManager.storageRef.child("images")
    let MAX_FILE_SIZE: Int64 = 5 * 1_024 * 1_024 // 5MB

    var imageCache = [String: Data]()

    private func uploadImage(data: Data, fileName: String,
                             completionHandler: @escaping (DatabaseError?, String?) -> Void) {
        let ref = imageRef.child(fileName)
        ref.putData(data, metadata: nil) { _, error in
            if error != nil {
                completionHandler(.fileCouldNotBeUploaded, nil)
                return
            }
            ref.downloadURL { url, _ in
                guard let downloadURL = url else {
                    completionHandler(.fileCouldNotBeUploaded, nil)
                    return
                }
                completionHandler(nil, downloadURL.absoluteString)
            }

        }
    }

    private func downloadImage(fileName: String, completionHandler: @escaping (DatabaseError?, Data?) -> Void) {
        if let cachedImageData = imageCache[fileName] {
            print("image retrieved from cache")
            completionHandler(nil, cachedImageData)
            return
        }
        let ref = imageRef.child(fileName)
        ref.getData(maxSize: MAX_FILE_SIZE) { data, error in
            if error != nil {
                completionHandler(.fileCouldNotBeDownloaded, nil)
                return
            }
            self.imageCache[fileName] = data
            completionHandler(nil, data)
        }
    }

    func uploadProductImage(productId: String, imageData: Data,
                            completionHandler: @escaping (DatabaseError?, String?) -> Void) {
        uploadImage(data: imageData, fileName: "product_\(productId).png", completionHandler: completionHandler)
    }

    func getProductImage(productId: String, completionHandler: @escaping (DatabaseError?, Data?) -> Void) {
        downloadImage(fileName: "product_\(productId).png", completionHandler: completionHandler)
    }

    func uploadShopImage(shopId: String, imageData: Data,
                         completionHandler: @escaping (DatabaseError?, String?) -> Void) {
        uploadImage(data: imageData, fileName: "shop_\(shopId).png", completionHandler: completionHandler)
    }

    func getShopImage(shopId: String, completionHandler: @escaping (DatabaseError?, Data?) -> Void) {
        downloadImage(fileName: "shop_\(shopId).png", completionHandler: completionHandler)
    }
}
