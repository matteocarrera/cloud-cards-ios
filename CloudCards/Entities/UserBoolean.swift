import Foundation
import RealmSwift

/*
    Класс Пользователя, сгенерированного на основе родительского Пользователя
 */

public class UserBoolean : Object, Codable {
    @objc dynamic var parentId : String = ""
    @objc dynamic var uuid : String = ""
    @objc dynamic var name : Bool = false
    @objc dynamic var surname : Bool = false
    @objc dynamic var patronymic : Bool = false
    @objc dynamic var company : Bool = false
    @objc dynamic var jobTitle : Bool = false
    @objc dynamic var mobile : Bool = false
    @objc dynamic var mobileSecond : Bool = false
    @objc dynamic var email : Bool = false
    @objc dynamic var emailSecond : Bool = false
    @objc dynamic var address : Bool = false
    @objc dynamic var addressSecond : Bool = false
    @objc dynamic var cardNumber : Bool = false
    @objc dynamic var cardNumberSecond : Bool = false
    @objc dynamic var website : Bool = false
    @objc dynamic var vk : Bool = false
    @objc dynamic var telegram : Bool = false
    @objc dynamic var facebook : Bool = false
    @objc dynamic var instagram : Bool = false
    @objc dynamic var twitter : Bool = false
    @objc dynamic var notes : Bool = false
    
    public override class func primaryKey() -> String? {
        return "uuid"
    }
}
