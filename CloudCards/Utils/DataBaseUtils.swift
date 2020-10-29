import Foundation
import UIKit
import FirebaseFirestore
import RealmSwift

public func saveUser(controller : UIViewController, link : String) {
    let parentId = String(link.split(separator: "|")[0])
    let uuid = String(link.split(separator: "|")[1])
    
    let db = FirestoreInstance.getInstance()
    db.collection(FirestoreInstance.USERS)
        .document(parentId)
        .collection(FirestoreInstance.CARDS)
        .document(uuid)
        .getDocument { (document, error) in
        if let document = document, document.exists {
            let dataDescription = document.data()
            
            let userBoolean = convertFromDictionary(dictionary: dataDescription!, type: UserBoolean.self)

            let realm = try! Realm()
            
            let existingUserDict = realm.objects(UserBoolean.self).filter("uuid = \"\(userBoolean.uuid)\"")
            
            if existingUserDict.count == 0 {
                
                try! realm.write {
                    realm.add(userBoolean)
                    print("User successfully added!")
                }
                
                realm.refresh()
                
                let alert = UIAlertController(title: "Успешно", message: "Контакт успешно считан!", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "ОК", style: .cancel, handler: { (_) in
                    controller.tabBarController?.selectedIndex = 1
                    controller.tabBarController?.selectedIndex = 0
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

public func getPhotoFromDatabase(photoUuid : String) -> UIImage? {
    let url = URL(string: getPhotoLink(uuid: photoUuid))
    let data = try? Data(contentsOf: url!)
    
    if let imageData = data {
        return UIImage(data: imageData)
    }
    
    return nil
}

private func getPhotoLink(uuid : String) -> String {
    return "https://firebasestorage.googleapis.com/v0/b/cloudcardsmobile.appspot.com/o/\(uuid)?alt=media"
}
