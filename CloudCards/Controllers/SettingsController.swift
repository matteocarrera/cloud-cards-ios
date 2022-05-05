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

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileViewTapped))
        profileView.isUserInteractionEnabled = true
        profileView.addGestureRecognizer(tapGestureRecognizer)

        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
    }

    public func getProfileInfo() {
        let userDictionary = RealmInstance.getInstance().objects(User.self)
        if userDictionary.isEmpty {
            return
        }

        let mainUser = userDictionary[0]

        nameLabel.text = "\(mainUser.name) \(mainUser.surname)"
        mobileLabel.text = mainUser.mobile
        emailLabel.text = mainUser.email
        profilePhoto.image = nil
        initialsLabel.isHidden = false
        initialsLabel.text = "\(mainUser.name.character(at: 0)!)\(mainUser.surname.character(at: 0)!)"

        loadingIndicator.startAnimating()

        FirebaseClientInstance.getInstance().getPhoto(setImageTo: profilePhoto, with: mainUser.photo) { result in
            switch result {
            case .success:
                self.initialsLabel.isHidden = true
                self.loadingIndicator.stopAnimating()
            case .failure(let error):
                self.loadingIndicator.stopAnimating()
                print(error)
            }
        }
    }

    @IBAction func openEditProfileWindow(_ sender: Any) {
        guard let viewController =
                storyboard?.instantiateViewController(withIdentifier: "EditProfileController")
                as? EditProfileController else {
            return
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func profileViewTapped() {
        guard let viewController =
                storyboard?.instantiateViewController(withIdentifier: "ProfileController")
                as? ProfileController else {
            return
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SettingsController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        cell.textLabel?.text = settingsRows[indexPath.row][0]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewControllerName = settingsRows[indexPath.row][1]
        let viewController = storyboard?.instantiateViewController(withIdentifier: viewControllerName)

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

extension SettingsController: UITableViewDelegate {

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
