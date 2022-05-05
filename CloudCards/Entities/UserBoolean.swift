import RealmSwift

/*
    Класс Пользователя, сгенерированного на основе родительского Пользователя
 */

public class UserBoolean: Object, Codable {

    @objc dynamic var parentId: String
    @objc dynamic var uuid: String
    @objc dynamic var name: Bool
    @objc dynamic var surname: Bool
    @objc dynamic var patronymic: Bool
    @objc dynamic var company: Bool
    @objc dynamic var jobTitle: Bool
    @objc dynamic var mobile: Bool
    @objc dynamic var mobileSecond: Bool
    @objc dynamic var email: Bool
    @objc dynamic var emailSecond: Bool
    @objc dynamic var address: Bool
    @objc dynamic var addressSecond: Bool
    @objc dynamic var website: Bool
    @objc dynamic var vk: Bool
    @objc dynamic var telegram: Bool
    @objc dynamic var facebook: Bool
    @objc dynamic var instagram: Bool
    @objc dynamic var twitter: Bool

    public override init() {
        parentId = String()
        uuid = String()
        name = false
        surname = false
        patronymic = false
        company = false
        jobTitle = false
        mobile = false
        mobileSecond = false
        email = false
        emailSecond = false
        address = false
        addressSecond = false
        website = false
        vk = false
        telegram = false
        facebook = false
        instagram = false
        twitter = false
    }

    public override class func primaryKey() -> String? {
        return "uuid"
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let secondUser = object as? UserBoolean else {
            return false
        }

        return name == secondUser.name &&
            surname == secondUser.surname &&
            patronymic == secondUser.patronymic &&
            company == secondUser.company &&
            jobTitle == secondUser.jobTitle &&
            mobile == secondUser.mobile &&
            mobileSecond == secondUser.mobileSecond &&
            email == secondUser.email &&
            emailSecond == secondUser.emailSecond &&
            address == secondUser.address &&
            addressSecond == secondUser.addressSecond &&
            website == secondUser.website &&
            vk == secondUser.vk &&
            telegram == secondUser.telegram &&
            facebook == secondUser.facebook &&
            instagram == secondUser.instagram &&
            twitter == secondUser.twitter
    }
}
