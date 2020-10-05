import UIKit
import RealmSwift
import FirebaseStorage

class ProfileController: UIViewController {

    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var createProfileNotification: UILabel!
    
    private let realm = try! Realm()
    
    // Массив данных пользователя
    private var data = [DataItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: tableView, controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        /*
            Получение данных основного пользователя приложения
         */
        
        let userDictionary = realm.objects(User.self)
        if userDictionary.count != 0 {
            createProfileNotification.isHidden = true
            
            let owner = userDictionary[0]
            
            userPhoto.isHidden = false
            userPhoto.image = getPhotoFromDatabase(photoUuid: owner.photo)
            
            data = setDataToList(user: owner)
        } else {
            createProfileNotification.isHidden = false
            userPhoto.isHidden = true
            data = [DataItem]()
        }
        
        userPhoto.layer.cornerRadius = userPhoto.frame.height/2
    
        tableView.reloadData()
    }
}

extension ProfileController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileDataCell", for: indexPath) as! ProfileDataCell
        
        let dataCell = data[indexPath.row]
        cell.descriptionText?.text = dataCell.description
        cell.titleText?.text = dataCell.title
        
        return cell
    }
}

extension ProfileController: UITableViewDelegate {}

class ProfileDataCell: UITableViewCell {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
