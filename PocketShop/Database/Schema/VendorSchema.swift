struct VendorSchema: Codable {
    var id: String

    init(vendor: Vendor) {
        self.id = vendor.id.strVal
    }

    func toVendor() -> Vendor {
        Vendor(id: ID(strVal: self.id))
    }
}
