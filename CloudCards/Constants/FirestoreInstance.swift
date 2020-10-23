import Foundation
import FirebaseFirestore

class FirestoreInstance {
    private static var db : Firestore? = nil
    
    static func getInstance() -> Firestore {
        if db == nil {
            db = Firestore.firestore()
        } 
        return db!
    }
}
