import RealmSwift

/*
    Основной класс Пользователя
 */

public class User: Object, Codable {
    
    // UUID родительского пользователя
    @objc dynamic var parentId: String
    
    // UUID, присвоенный конкретному пользователю
    @objc dynamic var uuid: String
    
    // UUID фотографии пользователя
    @objc dynamic var photo: String
    
    // Имя пользователя
    @objc dynamic var name: String
    
    // Фамилия пользователя
    @objc dynamic var surname: String
    
    // Отчество пользователя
    @objc dynamic var patronymic: String
    
    // Компания
    @objc dynamic var company: String
    
    // Должность
    @objc dynamic var jobTitle: String
    
    // Мобильный номер
    @objc dynamic var mobile: String
    
    // Мобильный номер дополнительный
    @objc dynamic var mobileSecond: String
    
    // Электронная почта
    @objc dynamic var email: String
    
    // Электронная почта дополнительная
    @objc dynamic var emailSecond: String
    
    // Адрес
    @objc dynamic var address: String
    
    // Адрес дополнительный
    @objc dynamic var addressSecond: String
    
    // Сайт
    @objc dynamic var website: String
    
    // Имя пользователя VK
    @objc dynamic var vk: String
    
    // Имя пользователя Telegram
    @objc dynamic var telegram: String
    
    // Имя пользователя Facebook
    @objc dynamic var facebook: String
    
    // Имя пользователя Instagram
    @objc dynamic var instagram: String
    
    // Имя пользователя Twitter
    @objc dynamic var twitter: String
    
    public override init() {
        parentId = String()
        uuid = String()
        photo = String()
        name = String()
        surname = String()
        patronymic = String()
        company = String()
        jobTitle = String()
        mobile = String()
        mobileSecond = String()
        email = String()
        emailSecond = String()
        address = String()
        addressSecond = String()
        website = String()
        vk = String()
        telegram = String()
        facebook = String()
        instagram = String()
        twitter = String()
    }
    
    public override class func primaryKey() -> String? {
        return "uuid"
    }
}
