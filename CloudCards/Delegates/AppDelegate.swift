import UIKit
import Firebase
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        let newSchemaVersion = UInt64(2)
        let config = Realm.Configuration(
            schemaVersion: newSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < newSchemaVersion {
                    migration.enumerateObjects(ofType: Card.className()) { oldObject, newObject in
                        guard let color = oldObject!["color"] as? String,
                              let title = oldObject!["title"] as? String,
                              let cardUuid = oldObject!["userId"] as? String else {
                            return
                        }
                        newObject!["uuid"] = UUID().uuidString.lowercased
                        newObject!["type"] = CardType.personal.rawValue
                        newObject!["color"] = color
                        newObject!["title"] = title
                        newObject!["cardUuid"] = cardUuid
                    }
                }
            })

        Realm.Configuration.defaultConfiguration = config

        let realm = try? Realm()
        // print(realm.configuration.fileURL)

        return true
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }
}
