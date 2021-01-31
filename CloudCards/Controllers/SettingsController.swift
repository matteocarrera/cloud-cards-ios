import UIKit

private let reuseIdentifier = "SettingsCell"

class SettingsController: UIViewController {

    @IBOutlet var profileView: UIView!
    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var mobileLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var settingsTable: UITableView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    private let settingsRows = [
        ["Конфиденциальность", "Privacy"],
        ["Пользовательское соглашение", "TermsOfUse"],
        ["Помощь", "Help"],
        ["О приложении", "AboutApp"]
    ]
    private let realm = RealmInstance.getInstance()
    private let firebaseClient = FirebaseClientInstance.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: settingsTable, controller: self)
        setLargeNavigationBar(for: self)
        
        getProfileInfo()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileViewTapped))
        profileView.isUserInteractionEnabled = true
        profileView.addGestureRecognizer(tapGestureRecognizer)
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
    }
    
    public func getProfileInfo() {
        DispatchQueue.main.async {
            let userDictionary = self.realm.objects(User.self)
            if userDictionary.count != 0 {
                let owner = userDictionary[0]
                
                self.nameLabel.text = "\(owner.name) \(owner.surname)"
                self.mobileLabel.text = owner.mobile
                self.emailLabel.text = owner.email
                if owner.photo != "" {
                    self.firebaseClient.getPhoto(with: owner.photo) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let image):
                                self.profilePhoto.image = image
                                self.showProfileView()
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                } else {
                    self.profilePhoto.image = nil
                    self.showProfileView()
                }
            } else {
                self.nameLabel.text = "Пользователь не найден"
                self.mobileLabel.text = "Телефон не найден"
                self.emailLabel.text = "Email не найден"
                self.showProfileView()
            }
        }
    }
    
    private func showProfileView() {
        profileView.isHidden = false
        loadingIndicator.stopAnimating()
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
