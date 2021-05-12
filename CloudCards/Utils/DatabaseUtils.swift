import UIKit

public func getUserFromQR(from controller: UIViewController, with link: String) {
    let idsString = link.split(separator: "#")[1]
    let ids = idsString.split(separator: ID_SEPARATOR.character(at: 0) ?? "&")
    let parentId = String(ids[0])
    let uuid = String(ids[1])
    let realm = RealmInstance.getInstance()
    
    let idPairList = realm.objects(IdPair.self)
    let currentIdPair = IdPair(parentUuid: parentId, uuid: uuid)
    if !idPairList.contains(currentIdPair) {
        let alert = UIAlertController(title: "Успешно", message: "Контакт успешно считан!", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "ОК", style: .cancel, handler: { (_) in
            let contactsController = controller.children[1].children.first as! ContactsController
            if contactsController.isViewLoaded {
                contactsController.loadingIndicator.startAnimating()
                contactsController.refreshTable(contactsController.self)
            }
        }))
        controller.present(alert, animated: true, completion: nil)
        
        try! realm.write {
            realm.add(currentIdPair)
        }
        
        return
    }
    
    showSimpleAlert(
        withTitle: "Ошибка",
        withMessage: "Такой пользователь уже существует!",
        inController: controller
    )
}

public func saveCard(
    withTitle title: String?,
    withColor selectedColor: String,
    withUserData selectedItems: [DataItem],
    withTemplateUserList templateUserList: [UserBoolean]
) {
    let realm = RealmInstance.getInstance()
    let ownerUser = realm.objects(User.self)[0]
    
    let newUser = parseDataToUserBoolean(from: selectedItems)
    newUser.parentId = ownerUser.parentId
    
    /*
        Делаем проверку на то, что визитка с выбранными полями уже существует
     */
    
    var userExists = false
    
    for templateUser in templateUserList {
        if newUser.isEqual(templateUser) {
            newUser.uuid = templateUser.uuid
            userExists = true
        }
    }
    
    if !userExists {
        let uuid = UUID().uuidString
        newUser.uuid = uuid
        
        let userData = JsonUtils.convertToDictionary(object: newUser, dictType: [String: Any]())
        
        let db = FirestoreInstance.getInstance()
        db.collection(FirestoreInstance.USERS)
            .document(newUser.parentId)
            .collection(FirestoreInstance.CARDS)
            .document(newUser.uuid)
            .setData(userData)

        try! realm.write {
            realm.add(IdPair(parentUuid: newUser.parentId, uuid: newUser.uuid))
        }
    }

    let card = Card()
    card.color = selectedColor
    card.title = title!
    card.userId = newUser.uuid
    
    let maxValue = realm.objects(Card.self).max(ofProperty: "id") as Int?
    if (maxValue != nil) {
        card.id = maxValue! + 1
    } else {
        card.id = 0
    }
    
    try! realm.write {
        realm.add(card)
    }
}
