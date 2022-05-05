import RealmSwift

/*
    Класс визитки пользователя в TemplatesController
 */

class Card: Object {

    // UUID шаблонной визитки
    @objc dynamic var uuid: String

    // Тип визитки (персональная/компании)
    @objc dynamic var type: String

    // Цвет визитки в формате #XXXXXX
    @objc dynamic var color: String

    // Название визитки
    @objc dynamic var title: String

    // UUID контакта/компании, хранящийся в шаблонной визитке
    @objc dynamic var cardUuid: String

    public override init() {
        self.uuid = String()
        self.type = CardType.personal.rawValue
        self.color = String()
        self.title = String()
        self.cardUuid = String()
    }

    public override class func primaryKey() -> String? {
        return "uuid"
    }
}
