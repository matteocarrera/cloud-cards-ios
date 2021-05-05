import Foundation
import RealmSwift

/*
    Класс визитки пользователя в TemplatesController
 */

class Card : Object {
    @objc dynamic var id : Int = 0
    @objc dynamic var color : String = ""
    @objc dynamic var title : String = ""
    @objc dynamic var userId : String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
