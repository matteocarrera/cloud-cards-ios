import UIKit
import RealmSwift
import FirebaseDatabase
import FirebaseStorage

class ContactsController: UIViewController {

    @IBOutlet var contactsTable: UITableView!
    
    public var selectedContactsUuid = [String]()
    
    private let realm = try! Realm()
    private var cardsController = CardsController()
    private var contacts = [UserBoolean]()
    private let selectedCounter : UIBarButtonItem = UIBarButtonItem(title: "0 выбрано", style: .plain, target: self, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: contactsTable, controller: self)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPressGestureRecognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)

        selectedCounter.tintColor = UIColor.black
        setToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        contacts.removeAll()
        selectedContactsUuid.removeAll()

        let userDictionary = realm.objects(User.self)
        if userDictionary.count != 0 {
            let owner = userDictionary[0]
            contacts = Array(realm.objects(UserBoolean.self).filter("parentId != \"\(owner.uuid)\""))
        } else {
            contacts = Array(realm.objects(UserBoolean.self))
        }
        
        contactsTable.reloadData()
        self.navigationController?.isToolbarHidden = true
    }
    
    @objc func deleteContacts(_ sender: Any) {
        for uuid in selectedContactsUuid {
            let userUuid = uuid.split(separator: "|")[1]
            
            let contact = self.realm.objects(UserBoolean.self).filter("uuid = \"\(userUuid)\"")[0]
            
            try! self.realm.write {
                self.realm.delete(contact)
            }
        }
        
        cancelSelection()
    }
    
    /*
        TODO("Сделать отправку ссылок на визитку пользователя, не QR кода")
     */
    
    @objc func shareContacts(_ sender: Any) {
        var images = [UIImage]()
        for contactLink in selectedContactsUuid {
            let image = generateQR(userLink: contactLink)
            images.append(image!)
        }
        
        let shareController = UIActivityViewController(activityItems: images, applicationActivities: [])
        self.present(shareController, animated: true)
        
        cancelSelection()
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let index = self.contactsTable.indexPathForRow(at: touchPoint)  {
                let contact = contacts[index.row]
                showContactMenu(contact: contact)
            }
        }
    }
    
    private func showContactMenu(contact : UserBoolean) {
        let alert = UIAlertController.init(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction.init(title: "QR код", style: .default, handler: { (_) in
            
            let qrController = self.storyboard?.instantiateViewController(withIdentifier: "QRController") as! QRController
            
            let contact = self.realm.objects(UserBoolean.self).filter("uuid = \"\(contact.uuid)\"")[0]
            let userLink = contact.parentId + "|" + contact.uuid

            qrController.userLink = userLink
            
            self.navigationController?.pushViewController(qrController, animated: true)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Поделиться", style: .default, handler: { (_) in
            
            let contact = self.realm.objects(UserBoolean.self).filter("uuid = \"\(contact.uuid)\"")[0]
            let userLink = contact.parentId + "|" + contact.uuid

            if let image = generateQR(userLink: userLink) {
                let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
                self.present(vc, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction.init(title: "Удалить", style: .default, handler: { (_) in
            try! self.realm.write {
                self.realm.delete(contact)
            }
            
            self.viewWillAppear(true)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
            
        self.present(alert, animated: true)
    }
    
    /*
        Нижний тулбар, появляется при множественном выборе визиток
     */
    
    private func setToolbar() {
        var items = [UIBarButtonItem]()
        
        items.append(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteContacts(_:))))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.shareContacts(_:))))
        
        self.navigationController?.toolbar.setItems(items, animated: true)
        self.navigationController?.toolbar.barTintColor = LIGHT_GRAY
        self.navigationController?.toolbar.isTranslucent = false
    }
    
    /*
        Сброс множественного выбора визиток
     */
    
    public func cancelSelection() {
        cardsController = self.parent as! CardsController
        
        setSelectButton()
        
        viewWillAppear(true)
        self.navigationController?.isToolbarHidden = true
        cardsController.multipleChoiceActivated = false
        cardsController.navigationItem.leftBarButtonItem = nil
    }
    
    /*
        Установка кнопки множественного выбора визиток
     */
    
    private func setSelectButton() {
        let select : UIBarButtonItem = UIBarButtonItem(
            image: cardsController.selectButton.image,
            style: UIBarButtonItem.Style.plain,
            target: cardsController,
            action: #selector(CardsController.selectMultiple(_:))
        )
        select.tintColor = PRIMARY

        cardsController.navigationItem.rightBarButtonItem = select
    }
}

extension ContactsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTable.dequeueReusableCell(withIdentifier: "ContactsDataCell", for: indexPath) as! ContactsDataCell
        cell.accessoryType = .none
        let user = contacts[indexPath.row]
        
        let ref = Database.database().reference().child(user.parentId).child(user.parentId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let json = snapshot.value as? String {

                let parentUser: User = convertFromJson(json: json, type: User.self)
                  
                let currentUser = getUserFromTemplate(user: parentUser, userBoolean: user)

                /*
                    TODO("Если пользователь без фотографии, то сделать две буквы вместо фотографии")
                 */
                
                cell.contactPhoto.image = getPhotoFromDatabase(photoUuid: parentUser.photo)
                cell.contactPhoto.layer.cornerRadius = cell.contactPhoto.frame.height/2
                  
                cell.contactName.text = currentUser.name + " " + currentUser.surname
                
                if currentUser.company != "" {
                    cell.contactCompany.text = currentUser.company
                } else {
                    cell.contactCompany.text = "Компания не указана"
                }
                
                if currentUser.jobTitle != "" {
                    cell.contactJobTitle.text = currentUser.jobTitle
                } else {
                    cell.contactJobTitle.text = "Должность не указана"
                }
             }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let dataCell = contacts[indexPath.row]
        let uuid = dataCell.parentId + "|" + dataCell.uuid
        
        if cardsController.multipleChoiceActivated {
            selectedContactsUuid.append(uuid)

            selectedCounter.title = "\(selectedContactsUuid.count) выбрано"
            cardsController.navigationItem.leftBarButtonItem = selectedCounter
            cell.accessoryType = .checkmark
            
            if self.navigationController?.isToolbarHidden == true {
                self.navigationController?.isToolbarHidden = false
                setToolbar()
            }
        } else {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
            viewController.userId = dataCell.uuid
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let dataCell = contacts[indexPath.row]
        let uuid = dataCell.parentId + "|" + dataCell.uuid
        
        selectedContactsUuid.remove(at: selectedContactsUuid.firstIndex(of: uuid)!)
        cell.accessoryType = .none
        
        if selectedContactsUuid.count == 0 {
            self.navigationController?.isToolbarHidden = true
            cardsController.navigationItem.leftBarButtonItem = nil
        } else {
            selectedCounter.title = "\(selectedContactsUuid.count) выбрано"
            cardsController.navigationItem.leftBarButtonItem = selectedCounter
        }
    }
}

extension ContactsController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
}

class ContactsDataCell : UITableViewCell {
    
    @IBOutlet var contactPhoto: UIImageView!
    @IBOutlet var contactName: UILabel!
    @IBOutlet var contactCompany: UILabel!
    @IBOutlet var contactJobTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setColorToSelectedRow(tableCell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
