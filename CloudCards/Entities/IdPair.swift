import RealmSwift

/*
    Класс пары ID, необходимых для получения данных по контакту
 */

public class IdPair: Object {

    // UUID визитки
    @objc dynamic var uuid: String

    // Родительский UUID визитки, по которой можно подгрузить данные
    @objc dynamic var parentUuid: String

    override init() {
        uuid = String()
        parentUuid = String()
    }

    init(parentUuid: String, uuid: String) {
        self.parentUuid = parentUuid
        self.uuid = uuid
    }

    public override class func primaryKey() -> String? {
        return "uuid"
    }

    public override func isEqual(_ object: Any?) -> Bool {
        let idPairOther = object as! IdPair
        return self.uuid == idPairOther.uuid && self.parentUuid == idPairOther.parentUuid
    }
}
