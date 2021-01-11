import UIKit

private let reuseIdentifier = "SettingsCell"

class SettingsController: UIViewController {

    @IBOutlet var profileView: UIView!
    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var mobileLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var settingsTable: UITableView!
    
    private let settingsRows = [
        ["Конфиденциальность", "Privacy"],
        ["Пользовательское соглашение", "TermsOfUse"],
        ["Помощь", "Help"],
        ["О приложении", "AboutApp"]
    ]
    private let realm = RealmInstance.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: settingsTable, controller: self)
        
        getProfileInfo()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileViewTapped))
        profileView.isUserInteractionEnabled = true
        profileView.addGestureRecognizer(tapGestureRecognizer)
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        
        setTopSeparator(table: settingsTable)
        setBottomSeparator(table: settingsTable)
    }
    
    public func getProfileInfo() {
        let userDictionary = realm.objects(User.self)
        if userDictionary.count != 0 {
            let owner = userDictionary[0]
            
            nameLabel.text = "\(owner.name) \(owner.surname)"
            mobileLabel.text = owner.mobile
            emailLabel.text = owner.email
            profilePhoto.image = getPhotoFromDatabase(photoUuid: owner.photo)
        } else {
            nameLabel.text = "Пользователь не найден"
            mobileLabel.text = "Телефон не найден"
            emailLabel.text = "Email не найден"
        }
    }
    
    @IBAction func openEditProfileWindow(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "EditProfileController") as! EditProfileController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func profileViewTapped() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ProfileController") as! ProfileController
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SettingsController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        cell.textLabel?.text = settingsRows[indexPath.row][0]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewControllerName = settingsRows[indexPath.row][1]
        let viewController = storyboard?.instantiateViewController(withIdentifier: viewControllerName)
        navigationController?.pushViewController(viewController!, animated: true)
        
        settingsTable.reloadData()
    }
}

extension SettingsController : UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsRows.count
    }
}
