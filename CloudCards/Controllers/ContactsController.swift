import UIKit
import RealmSwift
import FirebaseFirestore
import FirebaseStorage

class ContactsController: UIViewController {

    @IBOutlet var contactsTable: UITableView!
    @IBOutlet var importFirstContactNotification: UILabel!
    @IBOutlet var selectMultipleButton: UIBarButtonItem!
    
    public var selectedContactsUuid = [String]()
    
    private let realm = RealmInstance.getInstance()
    private var navigationBar = UINavigationBar()
    private var search = UISearchController()
    private var contacts = [UserBoolean]()
    private let selectedCounter : UIBarButtonItem = UIBarButtonItem(title: "0 выбрано", style: .plain, target: self, action: nil)
    
    // Флаг, показывающий, что пользователь выбрал функцмножественного выбора визиток
    public var multipleChoiceActivated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: contactsTable, controller: self)
        
        navigationBar = self.navigationController!.navigationBar
        navigationBar.prefersLargeTitles = true
        
        setLargeNavigationBar()
        setSearchBar()
        setSelectButton()

        selectedCounter.tintColor = UIColor.black
        setToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Сделано для устранения бага с зависанием заголовка при переходе на просмотр визитки
        self.navigationItem.title = "Контакты"
        self.navigationItem.largeTitleDisplayMode = .always
        
        if multipleChoiceActivated {
            cancelSelection()
        }
        
        contacts.removeAll()
        selectedContactsUuid.removeAll()

        let userDictionary = realm.objects(User.self)
        if userDictionary.count != 0 {
            let owner = userDictionary[0]
            contacts = Array(realm.objects(UserBoolean.self).filter("parentId != \"\(owner.uuid)\""))
        } else {
            contacts = Array(realm.objects(UserBoolean.self))
        }
        
        importFirstContactNotification.isHidden = contacts.count != 0
        
        contactsTable.reloadData()
        self.navigationController?.isToolbarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Сделано для устранения бага с зависанием заголовка при переходе на просмотр визитки
        self.navigationItem.title = ""
        self.navigationItem.largeTitleDisplayMode = .never
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
    
    /*
        Кнопка для множественного выбора
     */
    
    @objc func selectMultiple(_ sender: Any) {
        if multipleChoiceActivated {
            cancelSelection()
            //self.navigationItem.prompt = nil
        } else {
            let cancelButton : UIBarButtonItem = UIBarButtonItem(
                title: "Отменить",
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(selectMultiple(_:))
            )
            cancelButton.tintColor = PRIMARY

            self.navigationItem.rightBarButtonItem = cancelButton
            
            multipleChoiceActivated = true
        }
    }
    
    /*
        Добавляет стиль для большого варианта NavBar
     */

    private func setLargeNavigationBar() {
        
        self.navigationController?.view.backgroundColor = LIGHT_GRAY
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = LIGHT_GRAY
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        navigationBar.compactAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
    
    /*
        Добавляет строку поиска в NavBar
     */

    private func setSearchBar() {
        search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Поиск"
        search.searchBar.setValue("Отмена", forKey: "cancelButtonText")
        self.navigationItem.searchController = search
    }
    
    /*
        Нижний тулбар, появляется при множественном выборе визиток
     */
    
    private func setToolbar() {
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteContacts(_:)))
        trashButton.tintColor = PRIMARY
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.shareContacts(_:)))
        shareButton.tintColor = PRIMARY
        
        self.navigationController?.toolbar.setItems([trashButton, space, shareButton], animated: true)
        self.navigationController?.toolbar.barTintColor = LIGHT_GRAY
        self.navigationController?.toolbar.isTranslucent = false
    }
    
    /*
        Сброс множественного выбора визиток
     */
    
    public func cancelSelection() {
        setSelectButton()
        
        self.navigationController?.isToolbarHidden = true
        multipleChoiceActivated = false
        viewWillAppear(true)
    }
    
    /*
        Установка кнопки множественного выбора визиток
     */
    
    private func setSelectButton() {
        let select : UIBarButtonItem = UIBarButtonItem(
            image: selectMultipleButton.image,
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(selectMultiple(_:))
        )
        select.tintColor = PRIMARY

        self.navigationItem.rightBarButtonItem = select
    }
}

extension ContactsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTable.dequeueReusableCell(withIdentifier: "ContactsDataCell", for: indexPath) as! ContactsDataCell
        cell.accessoryType = .none
        let user = contacts[indexPath.row]
        
        let db = FirestoreInstance.getInstance()
        db.collection(FirestoreInstance.USERS)
            .document(user.parentId)
            .collection(FirestoreInstance.DATA)
            .document(user.parentId)
            .getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                
                let parentUser: User = convertFromDictionary(dictionary: dataDescription!, type: User.self)
                  
                let currentUser = getUserFromTemplate(user: parentUser, userBoolean: user)

                if parentUser.photo != "" {
                    cell.contactPhoto.image = getPhotoFromDatabase(photoUuid: parentUser.photo)
                    cell.contactInitials.isHidden = true
                } else {
                    cell.contactPhoto.image = nil
                    cell.contactPhoto.backgroundColor = PRIMARY
                    cell.contactInitials.isHidden = false
                    cell.contactInitials.text = String(currentUser.name.character(at: 0)!) + String(currentUser.surname.character(at: 0)!)
                }
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
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let dataCell = contacts[indexPath.row]
        let uuid = dataCell.parentId + "|" + dataCell.uuid
        
        if multipleChoiceActivated {
            selectedContactsUuid.append(uuid)

            //self.navigationItem.prompt = "\(selectedContactsUuid.count) выбрано"
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
            //self.navigationItem.prompt = nil
        } else {
            //self.navigationItem.prompt = "\(selectedContactsUuid.count) выбрано"
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let qr = showQR(at: indexPath)
        let share = shareContact(at: indexPath)
        let delete = deleteContact(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, share, qr])
    }
    
    func showQR(at indexPath: IndexPath) -> UIContextualAction {
        let person = contacts[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "ShowQR") { (action, view, completion) in
            
            let contact = self.realm.objects(UserBoolean.self).filter("uuid = \"\(person.uuid)\"")[0]
            
            let qrController = self.storyboard?.instantiateViewController(withIdentifier: "QRController") as! QRController
            qrController.contact = contact
            
            self.navigationController?.pushViewController(qrController, animated: true)
            
            completion(true)
        }
        action.image = UIImage(systemName: "qrcode")
        action.backgroundColor = PRIMARY
        return action
    }
    
    func shareContact(at indexPath: IndexPath) -> UIContextualAction {
        let contact = contacts[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Share") { (action, view, completion) in
            
            let contact = self.realm.objects(UserBoolean.self).filter("uuid = \"\(contact.uuid)\"")[0]
            let userLink = contact.parentId + "|" + contact.uuid

            if let image = generateQR(userLink: userLink) {
                let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
                self.present(vc, animated: true)
            }
            
            completion(true)
        }
        action.image = UIImage(systemName: "square.and.arrow.up")
        action.backgroundColor = GRAPHITE
        return action
    }
    
    func deleteContact(at indexPath: IndexPath) -> UIContextualAction {
        let contact = contacts[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            try! self.realm.write {
                self.realm.delete(contact)
            }
            
            self.contacts.remove(at: indexPath.row)
            self.contactsTable.deleteRows(at: [indexPath], with: .automatic)

            completion(true)
        }
        action.image = UIImage(systemName: "trash")
        return action
    }
}

extension ContactsController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Поиск
    }
}

extension ContactsController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

class ContactsDataCell : UITableViewCell {
    
    @IBOutlet var contactPhoto: UIImageView!
    @IBOutlet var contactName: UILabel!
    @IBOutlet var contactCompany: UILabel!
    @IBOutlet var contactJobTitle: UILabel!
    @IBOutlet var contactInitials: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setColorToSelectedRow(tableCell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
