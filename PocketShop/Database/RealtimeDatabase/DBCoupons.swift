import Firebase

class DBCoupons {
    func createCoupon(coupon: Coupon) {
        let ref = FirebaseManager.sharedManager.ref.child("coupons/").childByAutoId()
        guard let key = ref.key else {
            print("Unexpected error")
            return
        }
        var couponSchema = CouponSchema(coupon: coupon)
        couponSchema.id = key
        do {
            let jsonData = try JSONEncoder().encode(couponSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func deleteCoupon(id: String) {
        let ref = FirebaseManager.sharedManager.ref.child("coupons/\(id)")
        ref.removeValue { error, _ in
            if let error = error {
                print(error)
            }
        }
    }

    func editCoupon(coupon: Coupon) {
        let ref = FirebaseManager.sharedManager.ref.child("coupons/\(coupon.id)")
        let couponSchema = CouponSchema(coupon: coupon)
        do {
            let jsonData = try JSONEncoder().encode(couponSchema)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func observeAllCoupons(actionBlock: @escaping (DatabaseError?, [Coupon]?, DatabaseEvent?) -> Void) {
        let ref = FirebaseManager.sharedManager.ref.child("coupons")

        ref.observe(.childAdded) { snapshot in
            if let value = snapshot.value, let coupon = self.convertCoupon(couponJson: value) {
                actionBlock(nil, [coupon], .added)
            }
        }

        ref.observe(.childChanged) { snapshot in
            if let value = snapshot.value, let coupon = self.convertCoupon(couponJson: value) {
                actionBlock(nil, [coupon], .updated)
            }
        }

        ref.observe(.childRemoved) { snapshot in
            if let value = snapshot.value, let coupon = self.convertCoupon(couponJson: value) {
                actionBlock(nil, [coupon], .deleted)
            }
        }

    }

    private func convertCoupon(couponJson: Any) -> Coupon? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: couponJson)
            let couponSchema = try JSONDecoder().decode(CouponSchema.self, from: jsonData)
            let coupon = couponSchema.toCoupon()
            return coupon
        } catch {
            print(error)
            return nil
        }
    }
}
