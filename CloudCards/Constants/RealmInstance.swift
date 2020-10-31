import Foundation
import RealmSwift

class RealmInstance {
    private static var realm : Realm?
    
    static func getInstance() -> Realm {
        if realm == nil {
            realm = try! Realm()
        }
        return realm!
    }
}

