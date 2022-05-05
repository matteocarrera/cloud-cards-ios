import RealmSwift

class RealmInstance {
    private static var realm: Realm?

    static func getInstance() -> Realm {
        // print(Realm.Configuration.defaultConfiguration.fileURL)

        if realm == nil {
            realm = try? Realm()
        }

        return realm!
    }
}
