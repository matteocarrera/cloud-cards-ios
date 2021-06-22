import UIKit

class ProfileController: UIViewController {

    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var initialsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var createProfileNotification: UILabel!
    
    private let realm = RealmInstance.getInstance()
    private let firebaseClient = FirebaseClientInstance.getInstance()
    private var data = [DataItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: tableView, controller: self)
        userPhoto.layer.cornerRadius = userPhoto.frame.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
            Получение данных основного пользователя приложения
         */
        
        let userDictionary = realm.objects(User.self)
        if userDictionary.count != 0 {
            createProfileNotification.isHidden = true
            
            let owner = userDictionary[0]
            initialsLabel.isHidden = false
            initialsLabel.text = String(owner.name.character(at: 0)!) + String(owner.surname.character(at: 0)!)
            
            firebaseClient.getPhoto(setImageTo: userPhoto, with: owner.photo) { result in
                switch result {
                case .success(_):
                    self.initialsLabel.isHidden = true
                case .failure(let error):
                    print(error)
                }
            }
            
            data = setDataToList(from: owner)
        } else {
            createProfileNotification.isHidden = false
            userPhoto.isHidden = true
            data = [DataItem]()
        }
    
        tableView.reloadData()
    }
}

extension ProfileController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DataCell.reuseIdentifier, for: indexPath) as! DataCell

        return cell.update(with: data[indexPath.row])
    }
}

extension ProfileController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}
