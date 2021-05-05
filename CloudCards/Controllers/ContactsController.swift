import UIKit

private let reuseIdentifier = "ContactCell"

class ContactsController: UIViewController {

    @IBOutlet var contactsTable: UITableView!
    @IBOutlet var importFirstContactNotification: UILabel!
    @IBOutlet var selectMultipleButton: UIBarButtonItem!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    public var contactsSectionTitles = [String]()
    public var contactsDictionary = [String:[Contact]]()
    private let realm = RealmInstance.getInstance()
    private var filteredContacts = [Contact]()
    private var selectedContacts = [Contact]()
    private var field = Field.surname
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLargeNavigationBar(for: self)
        setSearchBar(for: self)
        setToolbar(for: self)
        setMultipleSelectionButton()
        configureTableView(table: contactsTable, controller: self)
        
        contactsTable.refreshControl = UIRefreshControl()
        contactsTable.refreshControl?.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        
        DispatchQueue.main.async {
            self.loadContacts()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.cancelMultipleSelection()
        }
    }
    
    @objc func refreshTable(_ sender: Any) {
        DispatchQueue.main.async {
            self.loadContacts()
            self.contactsTable.refreshControl?.endRefreshing()
        }
    }

    @objc func onDeleteContactsButtonTap(_ sender: Any) {
        let indexPaths = contactsTable.indexPathsForSelectedRows!
        for indexPath in indexPaths.reversed() {
            deleteContact(at: indexPath)
        }
        cancelMultipleSelection()
    }
    
    @objc func onShareContactsButtonTap(_ sender: Any) {
        DispatchQueue.main.async {
            var contactsInfo = [Any]()
            
            let userDictionary = self.realm.objects(User.self)
            if userDictionary.count != 0 {
                let owner = userDictionary[0]
                contactsInfo.append("\(owner.name) \(owner.surname) отправил(а) Вам несколько контактов:")
            } else {
                contactsInfo.append("Пользователь CloudCards отправил Вам несколько контактов:")
            }
            
            for contact in self.selectedContacts {
                guard let siteLink = generateSiteLink(with: contact.user) else { return }
                contactsInfo.append(siteLink)
            }
            
            let shareController = UIActivityViewController(activityItems: contactsInfo, applicationActivities: [])
            self.present(shareController, animated: true)
            
            self.cancelMultipleSelection()
        }
    }

    @objc func onMultipleSelectionButtonTap(_ sender: Any) {
        if contactsTable.isEditing {
            self.contactsTable.deselectSelectedRows(animated: true)
            cancelMultipleSelection()
        } else {
            contactsTable.setEditing(true, animated: true)
            let cancelButton : UIBarButtonItem = UIBarButtonItem(
                title: "Готово",
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(onMultipleSelectionButtonTap(_:))
            )
            cancelButton.tintColor = UIColor(named: "Primary")

            self.navigationItem.leftBarButtonItem = cancelButton
        }
    }
    
    private func loadContacts() {
        // Устанавливаем здесь, поскольку при обновлении списка контактов сортировка устанавливается по фамилии
        field = .surname
        setSortContactsButton()
        
        let userDictionary = realm.objects(User.self)
        let ownerUuid = userDictionary.count > 0 ? userDictionary[0].uuid : String()
        let userBooleanList = Array(realm.objects(UserBoolean.self).filter("parentId != \"\(ownerUuid)\""))
        if userBooleanList.count == 0 {
            loadingIndicator.stopAnimating()
            self.importFirstContactNotification.isHidden = false
        } else {
            self.importFirstContactNotification.isHidden = true
            getContactsFromDatabase(userBooleanList)
        }
    }

    private func cancelMultipleSelection() {
        setMultipleSelectionButton()
        selectedContacts.removeAll()
        navigationController?.isToolbarHidden = true
        contactsTable.setEditing(false, animated: true)
    }

    private func setMultipleSelectionButton() {
        let select : UIBarButtonItem = UIBarButtonItem(
            title: "Изм.",
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(onMultipleSelectionButtonTap(_:))
        )
        select.tintColor = UIColor(named: "Primary")

        navigationItem.leftBarButtonItem = select
    }

    private func setSortContactsButton() {
        let sortByNameAction = UIAction(title: "По имени") { (_) in
            sortContacts(in: self, by: .name)
            self.field = .name
            self.setSortContactsButton()
        }
        
        let sortBySurnameAction = UIAction(title: "По фамилии") { (_) in
            sortContacts(in: self, by: .surname)
            self.field = .surname
            self.setSortContactsButton()
        }
        
        let sortByCompanyAction = UIAction(title: "По компании") { (_) in
            sortContacts(in: self, by: .company)
            self.field = .company
            self.setSortContactsButton()
        }
        
        let sortByJobTitleAction = UIAction(title: "По должности") { (_) in
            sortContacts(in: self, by: .jobTitle)
            self.field = .jobTitle
            self.setSortContactsButton()
        }
        
        switch field {
        case .name:
            setCheckmarkForAction(action: sortByNameAction)
        case .surname:
            setCheckmarkForAction(action: sortBySurnameAction)
        case .company:
            setCheckmarkForAction(action: sortByCompanyAction)
        case .jobTitle:
            setCheckmarkForAction(action: sortByJobTitleAction)
        }
        
        let menu = UIMenu(title: "Сортировать:", children: [sortByNameAction, sortBySurnameAction, sortByCompanyAction, sortByJobTitleAction])
        
        navigationItem.rightBarButtonItems?[1] = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            menu: menu
        )
    }
    
    private func setCheckmarkForAction(action: UIAction) {
        action.setValue(UIImage(systemName: "checkmark"), forKey: "image")
    }
    
    private func getContactsFromDatabase(_ userBooleanList: [UserBoolean]) {
        var contacts = [Contact]()
        userBooleanList.forEach { userBoolean in
            // Получение пользователя для структуры Контакт
            FirebaseClientInstance.getInstance().getUser(
                firstKey: userBoolean.parentId,
                secondKey: userBoolean.parentId,
                firstKeyPath: FirestoreInstance.USERS,
                secondKeyPath: FirestoreInstance.DATA
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        let parentUser = convertFromDictionary(dictionary: data, type: User.self)
                        let currentUser = getUserFromTemplate(user: parentUser, userBoolean: userBoolean)
                        var contact = Contact(user: currentUser, image: nil)
                        
                        // Получение фотографии пользователя для структуры Контакт
                        FirebaseClientInstance.getInstance().getPhoto(with: currentUser.photo) { result in
                            switch result {
                            case .success(let image):
                                contact = Contact(user: currentUser, image: image)
                            case .failure(let error):
                                print(error)
                            }
                        }

                        contacts.append(contact)
                        
                        if contacts.count == userBooleanList.count {
                            sortContacts(in: self, with: contacts, by: .surname)
                            self.loadingIndicator.stopAnimating()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ContactsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchIsActivated() ? 1 : contactsSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIsActivated() {
            return filteredContacts.count
        }
        
        let contactKey = contactsSectionTitles[section]
        if let contactValues = contactsDictionary[contactKey] {
            return contactValues.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTable.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ContactCell

        if searchIsActivated() {
            cell.update(with: filteredContacts[indexPath.row])
        } else {
            let contactKey = contactsSectionTitles[indexPath.section]
            if let contactValues = contactsDictionary[contactKey] {
                cell.update(with: contactValues[indexPath.row])
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchIsActivated() ? nil : contactsSectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return searchIsActivated() ? nil : contactsSectionTitles
    }
}

// MARK: - UITableViewDelegate

extension ContactsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let contact = getUserFromRow(with: indexPath)

        if contactsTable.isEditing {
            selectedContacts.append(contact)

            cell.tintColor = UIColor(named: "Primary")
            
            if navigationController?.isToolbarHidden == true {
                navigationController?.isToolbarHidden = false
                setToolbar(for: self)
            }
        } else {
            let cardViewController = self.storyboard?.instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
            cardViewController.currentUser = contact.user
            let nav = UINavigationController(rootViewController: cardViewController)
            navigationController?.showDetailViewController(nav, sender: nil)
            contactsTable.deselectSelectedRows(animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let contact = getUserFromRow(with: indexPath)
        
        selectedContacts.remove(at: selectedContacts.firstIndex(of: contact)!)
        
        if selectedContacts.count == 0 {
            navigationController?.isToolbarHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let qr = showQRAction(at: indexPath)
        let share = shareAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, share, qr])
    }
    
    private func getUserFromRow(with indexPath : IndexPath) -> Contact {
        if searchIsActivated() {
            return filteredContacts[indexPath.row]
        }
        let contactKey = contactsSectionTitles[indexPath.section]
        let contactValues = contactsDictionary[contactKey]
        return contactValues![indexPath.row]
    }
}

// MARK: - RowButtons

extension ContactsController {
    
    func showQRAction(at indexPath: IndexPath) -> UIContextualAction {
        let contact = getUserFromRow(with: indexPath)
        let action = UIContextualAction(style: .normal, title: "ShowQR") { (action, view, completion) in
            showShareController(with: contact.user, in: self)
            completion(true)
        }
        action.image = UIImage(systemName: "qrcode")
        action.backgroundColor = UIColor(named: "Primary")
        return action
    }
    
    func shareAction(at indexPath: IndexPath) -> UIContextualAction {
        let contact = getUserFromRow(with: indexPath)
        let action = UIContextualAction(style: .normal, title: "Share") { (action, view, completion) in
            showShareLinkController(with: contact.user, in: self)
            completion(true)
        }
        action.image = UIImage(systemName: "square.and.arrow.up")
        action.backgroundColor = UIColor.darkGray
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.deleteContact(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: "trash")
        return action
    }
    
    private func deleteContact(at indexPath: IndexPath) {
        let contact = getUserFromRow(with: indexPath)
        
        try! realm.write {
            realm.delete(realm.objects(UserBoolean.self).filter("uuid = \"\(contact.user.uuid)\""))
        }

        // Удаляем контакт из словаря контактов
        let contactKey = contactsSectionTitles[indexPath.section]
        contactsDictionary[contactKey]?.removeAll(where: { $0.user.uuid == contact.user.uuid })
        
        // Удаляем ячейку таблицы с данным контактом
        contactsTable.deleteRows(at: [indexPath], with: .automatic)
        
        // Если на первую букву фамилии никого больше нет, то удаляем сначала букву из списка,
        // а уже после удаляем секцию в самой таблице, отображаемой на экране
        if !contactsDictionary[contactKey]!.contains(where: { $0.user.surname.prefix(1) == contact.user.surname.prefix(1) }) {
            contactsSectionTitles.removeAll(where: { $0 == String(contact.user.surname.prefix(1)) })
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            contactsTable.deleteSections(indexSet, with: .automatic)
        }
        
        importFirstContactNotification.isHidden = contactsSectionTitles.count != 0
    }
}

// MARK: - UISearchBarDelegate

extension ContactsController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
            self.contactsTable.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(with: searchBar, searchText: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(with: searchBar, searchText: searchText)
    }
    
    func updateSearchResults(with searchBar: UISearchBar, searchText: String) {
        var contacts = [Contact]()
        let contactsArrays = self.contactsDictionary.values
        
        contactsArrays.forEach { users in
            contacts.append(contentsOf: users)
        }
        
        filteredContacts.removeAll()
        switch searchBar.selectedScopeButtonIndex {
        case 1:
            filteredContacts = contacts.filter({ contact -> Bool in
                return contact.user.surname.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
        case 2:
            filteredContacts = contacts.filter({ contact -> Bool in
                return contact.user.company.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
        default:
            filteredContacts = contacts.filter({ contact -> Bool in
                return contact.user.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
        }
        contactsTable.reloadData()
    }
    
    func searchIsActivated() -> Bool {
        return self.navigationItem.searchController!.isActive && self.navigationItem.searchController?.searchBar.text != ""
    }
}
