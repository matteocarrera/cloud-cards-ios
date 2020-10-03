import UIKit
import RealmSwift
import FirebaseStorage

class ProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var createProfileNotification: UILabel!
    
    private let realm = try! Realm()
    
    // Массив данных пользователя
    private var data = [DataItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPhoto.layer.cornerRadius = userPhoto.frame.height/2
        configureTableView(table: tableView, controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        /*
            Получение данных основного пользователя приложения
         */
        
        let owner = realm.objects(User.self)
        if owner.count != 0 {
            createProfileNotification.isHidden = true
            
            userPhoto.isHidden = false
            userPhoto.image = DataBaseUtils.getPhotoFromDatabase(photoUuid: owner[0].photo)
            
            data = DataUtils.setDataToList(user: owner[0])
        } else {
            createProfileNotification.isHidden = false
            userPhoto.isHidden = true
            data = [DataItem]()
        }
    
        tableView.reloadData()
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileDataCell", for: indexPath) as! ProfileDataCell
        
        let dataCell = data[indexPath.row]
        cell.descriptionText?.text = dataCell.description
        cell.titleText?.text = dataCell.title
        
        return cell
    }
}

class ProfileDataCell : UITableViewCell {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
