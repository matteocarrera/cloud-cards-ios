import Foundation
import FirebaseFirestore

class Firestore {
    private static var db : Firestore? = nil
    
    static func getInstance() -> Firestore {
        if db == nil {
            db = Firestore.firestore()
        }
        return db!
    }
}
