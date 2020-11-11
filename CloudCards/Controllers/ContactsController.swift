import UIKit

class ContactsController: UIViewController {

    @IBOutlet var contactsTable: UITableView!
    @IBOutlet var importFirstContactNotification: UILabel!
    @IBOutlet var selectMultipleButton: UIBarButtonItem!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    // Флаг, показывающий, что пользователь выбрал функцию множественного выбора визиток
    public var multipleChoiceActivated = false
    public var selectedContactsUuid = [String]()
    
    private let realm = RealmInstance.getInstance()
    private var contactsDictionary = [String:[User]]()
    private var contactsSectionTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView(table: contactsTable, controller: self)
        setLargeNavigationBar()
        setSearchBar()
        setSelectButton()
        setToolbar()
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Сделано для устранения бага с зависанием заголовка при переходе на просмотр визитки
        self.navigationItem.title = "Контакты"
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.isToolbarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Сделано для устранения бага с зависанием заголовка при переходе на просмотр визитки
        self.navigationItem.title = ""
        self.navigationItem.largeTitleDisplayMode = .never
        
        cancelSelection()
        contactsTable.reloadData()
    }

    @objc func deleteContacts(_ sender: Any) {
        for uuid in selectedContactsUuid {
            let userUuid = uuid.split(separator: "|")[1]
            
            let contact = self.realm.objects(UserBoolean.self)
                .filter("uuid = \"\(userUuid)\"")[0]
            
            try! self.realm.write {
                self.realm.delete(contact)
            }
        }
        contactsTable.reloadData()
        cancelSelection()
    }
    
    /*
        TODO("Сделать отправку ссылок на визитку пользователя, не QR кода")
     */
    
    @objc func shareContacts(_ sender: Any) {
        var images = [UIImage]()
        for contactLink in selectedContactsUuid {
            guard let image = generateQR(userLink: contactLink) else { return }
            images.append(image)
        }
        
        let shareController = UIActivityViewController(activityItems: images, applicationActivities: [])
        self.present(shareController, animated: true)
        
        contactsTable.reloadData()
        cancelSelection()
    }
    
    /*
        Кнопка для множественного выбора
     */
    
    @objc func selectMultiple(_ sender: Any) {
        if multipleChoiceActivated {
            self.contactsTable.deselectSelectedRow(animated: true)
            cancelSelection()
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
    
    private func loadData() {
        contactsDictionary.removeAll()
        contactsSectionTitles.removeAll()
        selectedContactsUuid.removeAll()
        
        var usersBoolean = [UserBoolean]()
        let userDictionary = realm.objects(User.self)
        let ownerUuid = userDictionary.count > 0 ? userDictionary[0].uuid : String()
        usersBoolean = Array(realm.objects(UserBoolean.self).filter("parentId != \"\(ownerUuid)\""))
        usersBoolean.forEach { (user) in
            getUserFromDatabase(userBoolean: user)
        }
        if usersBoolean.count == 0 {
            loadingIndicator.stopAnimating()
            self.importFirstContactNotification.isHidden = false
        }
    }
    
    /*
        Добавляет стиль для большого варианта NavBar
     */

    private func setLargeNavigationBar() {
        let navigationBar = self.navigationController!.navigationBar
        
        navigationBar.prefersLargeTitles = true
        
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
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Поиск"
        search.searchBar.setValue("Отмена", forKey: "cancelButtonText")
        self.navigationItem.searchController = search
    }
    
    /*
        Нижний тулбар, появляется при множественном выборе визиток
     */
    
    private func setToolbar() {
        let trashButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(self.deleteContacts(_:))
        )
        trashButton.tintColor = PRIMARY
        
        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: self,
            action: nil
        )
        
        let shareButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(self.shareContacts(_:))
        )
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
        selectedContactsUuid.removeAll()
        self.navigationController?.isToolbarHidden = true
        multipleChoiceActivated = false
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
    
    /*
         Получение данных контакта из Firebase
     */

    public func getUserFromDatabase(userBoolean: UserBoolean) {
        let db = FirestoreInstance.getInstance()
        db.collection(FirestoreInstance.USERS)
            .document(userBoolean.parentId)
            .collection(FirestoreInstance.DATA)
            .document(userBoolean.parentId)
            .getDocument { (document, error) in
                if let document = document, document.exists {
                    guard let dataDescription = document.data() else { return }
                    
                    let parentUser = convertFromDictionary(dictionary: dataDescription, type: User.self)
                      
                    let currentUser = getUserFromTemplate(user: parentUser, userBoolean: userBoolean)

                    let contactKey = String(currentUser.surname.prefix(1))
                    if var contactValues = self.contactsDictionary[contactKey] {
                        contactValues.append(currentUser)
                        self.contactsDictionary[contactKey] = contactValues
                    } else {
                        self.contactsDictionary[contactKey] = [currentUser]
                    }

                    DispatchQueue.main.async {
                        self.contactsSectionTitles = [String](self.contactsDictionary.keys)
                        self.contactsSectionTitles = self.contactsSectionTitles.sorted(by: {$0 < $1})
                        
                        self.contactsTable.reloadData()
                    }
                }
            }
    }
}

extension ContactsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactsSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let contactKey = contactsSectionTitles[section]
        if let contactValues = contactsDictionary[contactKey] {
            return contactValues.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTable.dequeueReusableCell(withIdentifier: "ContactsDataCell", for: indexPath) as! ContactsDataCell
        
        cell.accessoryType = .none
        
        let contactKey = contactsSectionTitles[indexPath.section]
        if let contactValues = contactsDictionary[contactKey] {
            cell.update(with: contactValues[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactsSectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactsSectionTitles
    }
}

extension ContactsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let contact = getUserFromRow(with: indexPath)
        
        let uuid = "\(contact.parentId)|\(contact.uuid)"
        
        if multipleChoiceActivated {
            selectedContactsUuid.append(uuid)

            cell.accessoryType = .checkmark
            
            if self.navigationController?.isToolbarHidden == true {
                self.navigationController?.isToolbarHidden = false
                setToolbar()
            }
        } else {
            let cardViewController = storyboard?.instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
            cardViewController.currentUser = contact
            self.navigationController?.pushViewController(cardViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                loadingIndicator.stopAnimating()
                self.importFirstContactNotification.isHidden = self.contactsSectionTitles.count != 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let contact = getUserFromRow(with: indexPath)
        let uuid = "\(contact.parentId)|\(contact.uuid)"
        
        selectedContactsUuid.remove(at: selectedContactsUuid.firstIndex(of: uuid)!)
        cell.accessoryType = .none
        
        if selectedContactsUuid.count == 0 {
            self.navigationController?.isToolbarHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let qr = showQR(at: indexPath)
        let share = shareContact(at: indexPath)
        let delete = deleteContact(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, share, qr])
    }
    
    private func getUserFromRow(with indexPath : IndexPath) -> User {
        let contactKey = contactsSectionTitles[indexPath.section]
        let contactValues = contactsDictionary[contactKey]
        return contactValues![indexPath.row]
    }
}

extension ContactsController {
    
    func showQR(at indexPath: IndexPath) -> UIContextualAction {
        let contact = getUserFromRow(with: indexPath)
        let action = UIContextualAction(style: .normal, title: "ShowQR") { (action, view, completion) in

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
        let contact = getUserFromRow(with: indexPath)
        let action = UIContextualAction(style: .normal, title: "Share") { (action, view, completion) in

            let contactUuids = "\(contact.parentId)|\(contact.uuid)"

            if let image = generateQR(userLink: contactUuids) {
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
        let contact = getUserFromRow(with: indexPath)
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            try! self.realm.write {
                self.realm.delete(self.realm.objects(UserBoolean.self).filter("uuid = \"\(contact.uuid)\""))
            }

            // Удаляем контакт из словаря контактов
            let contactKey = self.contactsSectionTitles[indexPath.section]
            self.contactsDictionary[contactKey]?.removeAll(where: { $0.uuid == contact.uuid })
            
            // Удаляем ячейку таблицы с данным контактом
            self.contactsTable.deleteRows(at: [indexPath], with: .automatic)
            
            // Если на первую букву фамилии никого больше нет, то удаляем сначала букву из списка,
            // а уже после удаляем секцию в самой таблице, отображаемой на экране
            if !self.contactsDictionary[contactKey]!.contains(where: { $0.surname.prefix(1) == contact.surname.prefix(1) }) {
                self.contactsSectionTitles.removeAll(where: { $0 == String(contact.surname.prefix(1)) })
                let indexSet = IndexSet(arrayLiteral: indexPath.section)
                self.contactsTable.deleteSections(indexSet, with: .automatic)
            }
            
            self.importFirstContactNotification.isHidden = self.contactsSectionTitles.count != 0

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

    public func update(with user: User) {
        contactPhoto.image = getPhotoFromDatabase(photoUuid: user.photo)
        if contactPhoto.image == nil {
            contactInitials.isHidden = false
            contactInitials.text = String(user.name.character(at: 0)!) + String(user.surname.character(at: 0)!)
        }
        contactPhoto.layer.cornerRadius = contactPhoto.frame.height/2
          
        contactName.text = "\(user.name) \(user.surname)"
        
        if user.company != "" {
            contactCompany.text = user.company
        }
        
        if user.jobTitle != "" {
            contactJobTitle.text = user.jobTitle
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setColorToSelectedRow(tableCell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
