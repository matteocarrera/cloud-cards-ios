import Foundation
import RealmSwift

/*
    Класс пары ID, необходимых для получения данных по контакту
 */

public class IdPair: Object {
    @objc dynamic var uuid: String = String()
    @objc dynamic var parentUuid: String = String()

    override init() {}
    
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
