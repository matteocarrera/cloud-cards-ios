import UIKit
import RealmSwift
import FirebaseFirestore
import MessageUI

class CardViewController: UIViewController {

    @IBOutlet weak var cardDataTable: UITableView!
    @IBOutlet var cardPhoto: UIImageView!
    @IBOutlet var userInitialsLabel: UILabel!
    
    // ID пользователя, полученный при переходе в окно просмотра визитки из шаблонов или контактов
    public var userId = ""
    public var user: User?
    
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

        let userBoolean = realm.objects(UserBoolean.self).filter("uuid = \"\(userId)\"")[0]
        
        guard let contact = user == nil ? getUserFromFirebase(userBoolean: userBoolean) : user else { return }
        
        data = setDataToList(user: contact)
        
        if contact.photo != "" {
            cardPhoto.image = getPhotoFromDatabase(photoUuid: contact.photo)
            userInitialsLabel.isHidden = true
        } else {
            userInitialsLabel.text = String(contact.name.character(at: 0)!) + String(contact.surname.character(at: 0)!)
            userInitialsLabel.isHidden = false
        }
        
        cardDataTable.reloadData()
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
    
    private func getUserFromFirebase(userBoolean: UserBoolean) -> User {
        var currentUser = User()
        let db = FirestoreInstance.getInstance()
        db.collection(FirestoreInstance.USERS)
            .document(userBoolean.parentId)
            .collection(FirestoreInstance.DATA)
            .document(userBoolean.parentId)
            .getDocument { (document, error) in
            if let document = document, document.exists {
                    let userData = document.data()
                
                    let owner = convertFromDictionary(dictionary: userData!, type: User.self)
                      
                    currentUser = getUserFromTemplate(user: owner, userBoolean: userBoolean)
                } else {
                    print("Данные пользователя отсутствуют!")
                }
        }
        return currentUser
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
