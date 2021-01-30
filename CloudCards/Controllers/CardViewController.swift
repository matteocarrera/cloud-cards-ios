import UIKit
import MessageUI

private let reuseIdentifier = "DataCell"

class CardViewController: UIViewController {

    @IBOutlet weak var cardDataTable: UITableView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var cardPhoto: UIImageView!
    @IBOutlet var userInitialsLabel: UILabel!
    
    public var currentUser = User()
    
    private let realm = RealmInstance.getInstance()
    private let firebaseClient = FirebaseClientInstance.getInstance()
    // Массив данных пользователя из выбранной визитки
    private var data = [DataItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "Назад", style: .done, target: self, action: #selector(closeWindow(_:)))
        backButton.tintColor = PRIMARY
        navigationItem.leftBarButtonItem = backButton
        
        configureTableView(table: cardDataTable, controller: self)
        cardPhoto.layer.cornerRadius = cardPhoto.frame.height/2
        setExportButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Визитка"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserData()
        loadingIndicator.stopAnimating()
    }
    
    @objc func closeWindow(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func exportContact(_ sender: Any) {
        let alert = UIAlertController(
            title: "Экспорт контакта",
            message: "Вы действительно хотите экспортировать контакт?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.init(title: "Да", style: .default, handler: { (_) in
            exportToContacts(user: parseDataToUser(from: self.data), photo: self.cardPhoto.image, controller: self)
        }))
        alert.addAction(UIAlertAction.init(title: "Нет", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    private func loadUserData() {
        data = setDataToList(from: currentUser)
        
        if currentUser.photo != "" {
            firebaseClient.getPhoto(with: currentUser.photo) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        self.cardPhoto.image = image
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            userInitialsLabel.isHidden = true
        } else {
            userInitialsLabel.text = String(currentUser.name.character(at: 0)!) + String(currentUser.surname.character(at: 0)!)
            userInitialsLabel.isHidden = false
        }
        cardPhoto.isHidden = false
        
        cardDataTable.reloadData()
    }
    
    private func setExportButton() {
        let exportButton : UIBarButtonItem
        
        exportButton = UIBarButtonItem(
            image: UIImage.init(systemName: "square.and.arrow.up"),
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(exportContact(_:))
        )
        exportButton.tintColor = PRIMARY
        
        navigationItem.rightBarButtonItem = exportButton
    }
}

extension CardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cardDataTable.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! DataCell
        
        let dataCell = data[indexPath.row]
        cell.titleLabel.text = dataCell.title
        cell.dataLabel.text = dataCell.data
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = data[indexPath.row]
        
        performActionWithField(title: dataCell.title, description: dataCell.data, controller: self)
        
        cardDataTable.reloadData()
    }
}

extension CardViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
}

extension CardViewController: MFMailComposeViewControllerDelegate {}
