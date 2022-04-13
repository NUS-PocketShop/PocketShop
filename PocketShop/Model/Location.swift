import CoreLocation
struct Location: Hashable, Codable {
    var id: String
    var name: String = ""
    var address: String = ""
    var postalCode: Int = 0
    var imageURL: String = ""
    // var location: CLLocation? // Not codable by default, haven't figured out how to make it codable
}
