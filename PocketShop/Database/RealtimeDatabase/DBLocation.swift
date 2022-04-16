import Firebase

class DBLocation {
    func createLocation(location: Location) {
        let ref = FirebaseManager.sharedManager.ref.child("locations/").childByAutoId()
        guard let key = ref.key else {
            print("Unexpected error")
            return
        }
        var newLocation = location
        newLocation.id = key
        do {
            let jsonData = try JSONEncoder().encode(newLocation)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func deleteLocation(id: String) {
        let ref = FirebaseManager.sharedManager.ref.child("locations/\(id)")
        ref.removeValue { error, _ in
            if let error = error {
                print(error)
            }
        }
    }

    func editLocation(location: Location) {
        let ref = FirebaseManager.sharedManager.ref.child("locations/\(location.id)")
        do {
            let jsonData = try JSONEncoder().encode(location)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            ref.setValue(json)
        } catch {
            print(error)
        }
    }

    func observeAllLocations(actionBlock: @escaping (DatabaseError?, [Location]?, DatabaseEvent?) -> Void) {
        let ref = FirebaseManager.sharedManager.ref.child("locations")

        ref.observe(.childAdded) { snapshot in
            if let value = snapshot.value, let location = self.convertLocation(locationJson: value) {
                actionBlock(nil, [location], .added)
            }
        }

        ref.observe(.childChanged) { snapshot in
            if let value = snapshot.value, let location = self.convertLocation(locationJson: value) {
                actionBlock(nil, [location], .updated)
            }
        }

        ref.observe(.childRemoved) { snapshot in
            if let value = snapshot.value, let location = self.convertLocation(locationJson: value) {
                actionBlock(nil, [location], .deleted)
            }
        }

    }

    private func convertLocation(locationJson: Any) -> Location? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: locationJson)
            let location = try JSONDecoder().decode(Location.self, from: jsonData)
            return location
        } catch {
            print(error)
            return nil
        }
    }
}
