import Foundation
import UIKit

public func getUserFromQR(from controller: UIViewController, with link: String) {
    let ids = link.split(separator: ID_SEPARATOR.character(at: 0) ?? "&")
    let parentId = String(ids[0])
    let uuid = String(ids[1])
    
    let db = FirestoreInstance.getInstance()
    db.collection(FirestoreInstance.USERS)
        .document(parentId)
        .collection(FirestoreInstance.CARDS)
        .document(uuid)
        .getDocument { (document, error) in
        if let document = document, document.exists {
            let dataDescription = document.data()
            
            let userBoolean = convertFromDictionary(dictionary: dataDescription!, type: UserBoolean.self)

            let realm = RealmInstance.getInstance()
            
            let existingUserDict = realm.objects(UserBoolean.self).filter("uuid = \"\(userBoolean.uuid)\"")
            
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

public func getPhotoFromDatabase(photoUuid: String) -> UIImage? {
    let url = URL(string: getPhotoLink(uuid: photoUuid))
    let data = try? Data(contentsOf: url!)
    
    if let imageData = data {
        return UIImage(data: imageData)
    }
    
    return nil
}

private func getPhotoLink(uuid: String) -> String {
    return "https://firebasestorage.googleapis.com/v0/b/cloudcardsmobile.appspot.com/o/\(uuid)?alt=media"
}
