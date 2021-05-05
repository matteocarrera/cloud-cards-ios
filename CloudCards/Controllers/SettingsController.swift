import UIKit

private let reuseIdentifier = "SettingsCell"

class SettingsController: UIViewController {

    @IBOutlet var profileView: UIView!
    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var initialsLabel: UILabel!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: settingsTable, controller: self)
        setLargeNavigationBar(for: self)
        
        getProfileInfo()
        
        if !Reachability.isConnectedToNetwork() {
            navigationItem.rightBarButtonItem?.isEnabled = false
            showSimpleAlert(
                withTitle: "Предупреждение",
                withMessage: "При отсутствии интернета Вы не можете создавать/редактировать профиль!",
                inController: self
            )
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileViewTapped))
        profileView.isUserInteractionEnabled = true
        profileView.addGestureRecognizer(tapGestureRecognizer)
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
    }
    
    public func getProfileInfo() {
        DispatchQueue.main.async {
            let userDictionary = RealmInstance.getInstance().objects(User.self)
            if userDictionary.count != 0 {
                let owner = userDictionary[0]
                
                self.nameLabel.text = "\(owner.name) \(owner.surname)"
                self.mobileLabel.text = owner.mobile
                self.emailLabel.text = owner.email
                self.profilePhoto.image = nil
                self.initialsLabel.isHidden = false
                self.initialsLabel.text = String(owner.name.character(at: 0)!) + String(owner.surname.character(at: 0)!)
                if owner.photo != "" {
                    FirebaseClientInstance.getInstance().getPhoto(with: owner.photo) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(var image):
                                self.initialsLabel.isHidden = true
                                image = image.resizeWithPercent(percentage: 0.5)!
                                self.profilePhoto.image = image
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                }
            }
            self.showProfileView()
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
        
        #warning("Временная заглушка")
        if indexPath.row == 3 {
            navigationController?.pushViewController(viewController!, animated: true)
        } else {
            showTimeAlert(
                withTitle: "Недоступно",
                withMessage: "Данный раздел временно недоступен",
                showForSeconds: 1.5,
                inController: self
            )
        }
        
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
