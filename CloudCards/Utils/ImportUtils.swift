import UIKit
import RealmSwift

class ImportUtils {

    /*
        Метод, отвечающий за импорт контакта в приложение
     */

    class func getUserFromQR(from controller: UIViewController, with link: String) {
        let idsString = link.split(separator: "#")[1]
        let linkBody = idsString.split(separator: ID_SEPARATOR.character(at: 0) ?? "&")
        let parentId = String(linkBody[0])
        let uuid = String(linkBody[1])
        let type = linkBody.count == 3 ? String(linkBody[2]) : CardType.personal.rawValue
        let realm = RealmInstance.getInstance()

        let idPairList = realm.objects(IdPair.self)
        let userList = realm.objects(User.self)
        let ownerUser = userList.count != 0 ? userList[0] : nil

        // Запрет на добавление своей же визитки
        if parentId == ownerUser?.uuid {
            showSimpleAlert(
                withTitle: "Ошибка",
                withMessage: "Вы не можете отсканировать свою визитку!",
                inController: controller
            )
            return
        }

        // Если у пользователя уже есть визитки данного контакта, то мы берем все на проверку
        let currentParentIdCards = idPairList.filter({ $0.parentUuid == parentId })

        /*
            Если тип импортируемой визитки Персональная и количество визиток не 0, то проверяем
            все существующие визитки от данного контакта на наличие персональной визитки.
            Если такая уже существует, то выдаем ошибку. Допускается возможность хранения визиток
            компаний от одного и того же контакта, но их дублирование запрещено
         */
        if type == CardType.personal.rawValue && currentParentIdCards.count != 0 {
            var counter = 0
            currentParentIdCards.forEach { idPair in
                FirebaseClientInstance.getInstance().getUser(idPair: idPair) { result in
                    switch result {
                    case .success(let data):
                        let cardType = CardType(rawValue: data["type"] as? String ?? String())
                        if cardType == .personal || cardType == nil {
                            showSimpleAlert(
                                withTitle: "Ошибка",
                                withMessage: "Визитка данного пользователя уже существует!",
                                inController: controller
                            )
                            return
                        }
                        counter += 1
                        if counter == currentParentIdCards.count {
                            importContact(parentId, uuid, idPairList, controller, realm)
                            return
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        } else {
            importContact(parentId, uuid, idPairList, controller, realm)
        }
    }

    /*
        Метод, проверящий наличие такой пары ID в БД телефона
     */

    private class func importContact(_ parentId: String,
                                     _ uuid: String,
                                     _ idPairList: Results<IdPair>,
                                     _ controller: UIViewController,
                                     _ realm: Realm) {
        let currentIdPair = IdPair(parentUuid: parentId, uuid: uuid)
        if !idPairList.contains(currentIdPair) {
            let alert = UIAlertController(title: "Успешно", message: "Визитка успешно считана!", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "ОК", style: .cancel, handler: { (_) in
                guard let contactsController = controller.children[1].children.first as? ContactsController else {
                    return
                }
                if contactsController.isViewLoaded {
                    contactsController.refreshTable(contactsController.self)
                }
            }))
            controller.present(alert, animated: true, completion: nil)

            try? realm.write {
                realm.add(currentIdPair)
            }

            return
        }

        showSimpleAlert(
            withTitle: "Ошибка",
            withMessage: "Такая визитка уже существует!",
            inController: controller
        )
    }
}
