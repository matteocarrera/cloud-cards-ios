import Foundation
import UIKit

public func getUserFromQR(from controller: UIViewController, with link: String) {
    if !link.contains(CLOUDCARDS_WEBSITE) {
        return
    }
    let idsString = link.split(separator: "#")[1]
    let ids = idsString.split(separator: ID_SEPARATOR.character(at: 0) ?? "&")
    let parentId = String(ids[0])
    let uuid = String(ids[1])
    
    let firebaseClient = FirebaseClientInstance.getInstance()
    firebaseClient.getUser(firstKey: parentId, secondKey: uuid) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let data):
                let userBoolean = convertFromDictionary(dictionary: data, type: UserBoolean.self)
                
                let realm = RealmInstance.getInstance()
                
                let existingUserDict = realm.objects(UserBoolean.self).filter("parentId = \"\(userBoolean.parentId)\"")
                
                if existingUserDict.count == 0 {
                    
                    try! realm.write {
                        realm.add(userBoolean)
                    }
                    
                    realm.refresh()
                    
                    let alert = UIAlertController(title: "Успешно", message: "Контакт успешно считан!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "ОК", style: .cancel, handler: { (_) in
                        let contactsController = controller.children[1].children.first as! ContactsController
                        contactsController.refresh(contactsController)
                    }))
                    controller.present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    let alert = UIAlertController(title: "Ошибка", message: "Такой пользователь уже существует!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "ОК", style: .cancel))
                    controller.present(alert, animated: true, completion: nil)
                    
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

public func saveCard(withTitle title: String?, withColor selectedColor: String, withUserData selectedItems: [DataItem]) {
    let realm = RealmInstance.getInstance()
    let ownerUser = realm.objects(User.self)[0]
    
    let newUser = parseDataToUserBoolean(from: selectedItems)
    newUser.parentId = ownerUser.parentId
    
    let userDictionary = realm.objects(UserBoolean.self)
    
    /*
        Делаем проверку на то, что визитка с выбранными полями уже существует
     */
    
    var userExists = false
    
    for user in userDictionary {
        if newUser.isEqual(user) {
            newUser.uuid = user.uuid
            userExists = true
        }
    }
    
    if !userExists {
        let uuid = UUID().uuidString
        newUser.uuid = uuid
        
        let userData = convertToDictionary(someUser: newUser)
        
        let db = FirestoreInstance.getInstance()
        db.collection(FirestoreInstance.USERS)
            .document(newUser.parentId)
            .collection(FirestoreInstance.CARDS)
            .document(newUser.uuid)
            .setData(userData)

        try! realm.write {
            realm.add(newUser)
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
