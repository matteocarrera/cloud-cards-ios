import Foundation
import UIKit
import FirebaseDatabase
import RealmSwift

class DataBaseUtils {
    public static func saveUser(controller : UIViewController, link : String) {
        let parentId = link.split(separator: "|")[0]
        let uuid = link.split(separator: "|")[1]
        
        let ref = Database.database().reference().child(String(parentId)).child(String(uuid))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
             if let json = snapshot.value as? String {

                let userBoolean = convertFromJson(json: json, type: UserBoolean.self)

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
        })
    }
    
    private static func getPhotoLink(uuid : String) -> String {
        return "https://firebasestorage.googleapis.com/v0/b/alfa-bank-qr.appspot.com/o/\(uuid)?alt=media"
    }
    
    public static func getPhotoFromDatabase(photoUuid : String) -> UIImage? {
        let url = URL(string: getPhotoLink(uuid: photoUuid))
        let data = try? Data(contentsOf: url!)
        
        if let imageData = data {
            return UIImage(data: imageData)
        }
        
        return nil
    }
}
