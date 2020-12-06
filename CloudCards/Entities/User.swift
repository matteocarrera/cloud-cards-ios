import Foundation
import RealmSwift

/*
    Основной класс Пользователя
 */

public class User : Object, Codable {
    // UUID родительского пользователя
    @objc dynamic var parentId : String = ""
    
    // UUID, присвоенный конкретному пользователю
    @objc dynamic var uuid : String = ""
    
    @objc dynamic var photo : String = ""
    @objc dynamic var name : String = ""
    @objc dynamic var surname : String = ""
    @objc dynamic var patronymic : String = ""
    @objc dynamic var company : String = ""
    @objc dynamic var jobTitle : String = ""
    @objc dynamic var mobile : String = ""
    @objc dynamic var mobileSecond : String = ""
    @objc dynamic var email : String = ""
    @objc dynamic var emailSecond : String = ""
    @objc dynamic var address : String = ""
    @objc dynamic var addressSecond : String = ""
    @objc dynamic var cardNumber : String = ""
    @objc dynamic var cardNumberSecond : String = ""
    @objc dynamic var website : String = ""
    @objc dynamic var vk : String = ""
    @objc dynamic var telegram : String = ""
    @objc dynamic var facebook : String = ""
    @objc dynamic var instagram : String = ""
    @objc dynamic var twitter : String = ""
    @objc dynamic var notes : String = ""
    
    public override class func primaryKey() -> String? {
        return "uuid"
    }
}
