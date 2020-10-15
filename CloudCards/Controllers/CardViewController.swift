import UIKit
import RealmSwift
import FirebaseDatabase
import MessageUI

class CardViewController: UIViewController {

    @IBOutlet weak var cardDataTable: UITableView!
    @IBOutlet var cardPhoto: UIImageView!
    
    private let realm = try! Realm()
    
    // Массив данных пользователя из выбранной визитки
    private var data = [DataItem]()
    // ID пользователя, полученный при переходе в окно просмотра визитки из шаблонов или контактов
    public var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let exportButton : UIBarButtonItem
        
        if #available(iOS 13.0, *) {
            exportButton = UIBarButtonItem(
                image: UIImage.init(systemName: "square.and.arrow.up"),
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(exportContact(_:))
            )
        } else {
            exportButton = UIBarButtonItem(
                title: "Поделиться",
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(exportContact(_:))
            )
        }
        exportButton.tintColor = PRIMARY

        self.navigationItem.rightBarButtonItem = exportButton
        
        cardPhoto.layer.cornerRadius = cardPhoto.frame.height/2
        configureTableView(table: cardDataTable, controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userBoolean = realm.objects(UserBoolean.self).filter("uuid = \"\(userId)\"")[0]
        
        let ref = Database.database().reference().child(userBoolean.parentId).child(userBoolean.parentId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let json = snapshot.value as? String {

                let owner = convertFromJson(json: json, type: User.self)
                  
                let currentUser = getUserFromTemplate(user: owner, userBoolean: userBoolean)
                
                self.data = setDataToList(user: currentUser)
                
                self.cardPhoto.image = getPhotoFromDatabase(photoUuid: owner.photo)
                  
                self.cardDataTable.reloadData()
             }
        })
        
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
