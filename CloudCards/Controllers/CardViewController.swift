import UIKit
import MessageUI

class CardViewController: UIViewController {

    @IBOutlet weak var cardDataTable: UITableView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var cardPhoto: UIImageView!
    @IBOutlet var userInitialsLabel: UILabel!
    
    public var currentUser = User()
    
    private let realm = RealmInstance.getInstance()
    // Массив данных пользователя из выбранной визитки
    private var data = [DataItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: cardDataTable, controller: self)
        cardPhoto.layer.cornerRadius = cardPhoto.frame.height/2
        setExportButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Визитка"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserData()
        loadingIndicator.stopAnimating()
    }
    
    @objc func exportContact(_ sender: Any) {
        let alert = UIAlertController(
            title: "Экспорт контакта",
            message: "Вы действительно хотите экспортировать контакт?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.init(title: "Да", style: .default, handler: { (_) in
            exportToContacts(user: parseDataToUser(data: self.data), photo: self.cardPhoto.image, controller: self)
        }))
        alert.addAction(UIAlertAction.init(title: "Нет", style: .cancel))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func loadUserData() {
        data = setDataToList(user: currentUser)
        
        if currentUser.photo != "" {
            cardPhoto.image = getPhotoFromDatabase(photoUuid: currentUser.photo)
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
        
        self.navigationItem.rightBarButtonItem = exportButton
    }
}

extension CardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cardDataTable.dequeueReusableCell(withIdentifier: "CardDataCell", for: indexPath) as! CardDataCell
        
        let dataCell = data[indexPath.row]
        cell.itemTitle.text = dataCell.title
        cell.itemDescription.text = dataCell.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = data[indexPath.row]
        
        performActionWithField(title: dataCell.title, description: dataCell.description, controller: self)
        
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

class CardDataCell : UITableViewCell {
    
    @IBOutlet var itemTitle: UILabel!
    @IBOutlet var itemDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setColorToSelectedRow(tableCell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
