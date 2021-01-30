import UIKit

private let reuseIdentifier = "DataCell"

class ProfileController: UIViewController {

    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var createProfileNotification: UILabel!
    
    private let realm = RealmInstance.getInstance()
    private let firebaseClient = FirebaseClientInstance.getInstance()
    
    // Массив данных пользователя
    private var data = [DataItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: tableView, controller: self)
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
            
            userPhoto.isHidden = false
            firebaseClient.getPhoto(with: owner.photo) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        self.userPhoto.image = image
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
            data = setDataToList(from: owner)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! DataCell
        
        let dataCell = data[indexPath.row]
        cell.titleLabel?.text = dataCell.title
        cell.dataLabel?.text = dataCell.data
        
        return cell
    }
}

extension ProfileController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
}
