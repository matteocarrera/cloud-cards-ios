import FirebaseFirestore

class FirestoreInstance {
    public static let USERS = "users"
    public static let DATA = "data"
    public static let CARDS = "cards"

    private static var db: Firestore?

    static func getInstance() -> Firestore {
        if db == nil {
            db = Firestore.firestore()
        }
        return db!
    }

    static func getBusinessCards(_ idPairList: [IdPair], completion: @escaping (Result<([User], [Company]), Error>) -> Void) {
        var users = [User]()
        var companies = [Company]()
        // Получение визитки с выбранными полями для каждой пары ID
        idPairList.forEach { idPair in
            let idPair = IdPair(parentUuid: idPair.parentUuid, uuid: idPair.uuid)
            FirebaseClientInstance.getInstance().getUser(idPair: idPair) { result in
                switch result {
                case .success(let data):
                    var userBoolean = UserBoolean()
                    let cardType = CardType(rawValue: data["type"] as? String ?? String())

                    switch cardType {
                    case .personal:
                        let businessCard = JsonUtils.convertFromDictionary(dictionary: data, type: BusinessCard<UserBoolean>.self)
                        userBoolean = businessCard.data
                    case .company:
                        let businessCard = JsonUtils.convertFromDictionary(dictionary: data, type: BusinessCard<Company>.self)
                        companies.append(businessCard.data)
                        if users.count + companies.count == idPairList.count {
                            completion(.success((users, companies)))
                        }
                        return
                    default:
                        userBoolean = JsonUtils.convertFromDictionary(dictionary: data, type: UserBoolean.self)
                    }

                    // Получение пользователя для структуры Контакт
                    let idPairMainUser = IdPair(parentUuid: idPair.parentUuid, uuid: idPair.parentUuid)

                    FirebaseClientInstance.getInstance().getUser(idPair: idPairMainUser, pathToData: true) { result in
                        switch result {
                        case .success(let data):
                            // Генерация конечного контакта для отображения
                            let parentUser = JsonUtils.convertFromDictionary(dictionary: data, type: User.self)
                            let currentUser = getUserFromTemplate(user: parentUser, userBoolean: userBoolean)

                            users.append(currentUser)
                            if users.count + companies.count == idPairList.count {
                                completion(.success((users, companies)))
                            }

                        case .failure(let error):
                            completion(.failure(error))
                            print(error)
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print(error)
                }
            }
        }
    }
}
