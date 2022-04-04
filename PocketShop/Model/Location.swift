import CoreLocation
struct Location: Hashable {
    var id: String
    var name: String
    var address: String
    var postalCode: Int
    var imageURL: String
    var location: CLLocation
}
