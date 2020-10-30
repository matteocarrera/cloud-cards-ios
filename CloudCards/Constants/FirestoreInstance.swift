import Foundation
import FirebaseFirestore

class FirestoreInstance {
    public static let USERS = "users"
    public static let DATA = "data"
    public static let CARDS = "cards"
    
    private static var db : Firestore?
    
    static func getInstance() -> Firestore {
        if db == nil {
            db = Firestore.firestore()
        } 
        return db!
    }
}
