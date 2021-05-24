import UIKit

private let reuseIdentifierForContact = "ContactCell"
private let reuseIdentifietForCompany = "CompanyCell"

class ContactsController: UIViewController {

    @IBOutlet var contactsTable: UITableView!
    @IBOutlet var importFirstContactNotification: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    public var contactsSectionTitles = [String]()
    public var contactsDictionary = [String:[Contact]]()
    private let realm = RealmInstance.getInstance()
    private var companyCards = [Company]()
    private var selectedContacts = [Contact]()
    private var selectedCompanies = [Company]()
    private var field = Field.surname
    private var selectedSectionIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLargeNavigationBar(for: self)
        setSegmentedControl(for: self)
        setSearchBar(for: self)
        setContactsMenu()
        configureTableView(table: contactsTable, controller: self)
        
        loadingIndicator.layer.zPosition = 1
        importFirstContactNotification.layer.zPosition = 1
        
        contactsTable.refreshControl = UIRefreshControl()
        contactsTable.refreshControl?.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        
        DispatchQueue.main.async {
            self.loadContacts()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        DispatchQueue.main.async {
            self.cancelMultipleSelection()
            self.setContactsMenu()
        }
    }
    
    /*
        Метод, позволяющий обновить содержимое таблицы
     */
    
    @objc func refreshTable(_ sender: Any) {
        DispatchQueue.main.async {
            self.loadContacts()
            self.contactsTable.refreshControl?.endRefreshing()
        }
    }
    
    /*
        Метод, определяющий поведение кнопки удаления контактов
     */

    @objc func onDeleteContactsButtonTap(_ sender: Any) {
        let indexPaths = contactsTable.indexPathsForSelectedRows!
        for indexPath in indexPaths.reversed() {
            deleteContact(at: indexPath)
        }
        cancelMultipleSelection()
    }
    
    /*
        Метод, определяющий поведение кнопки поделиться контактами
     */
    
    @objc func onShareContactsButtonTap(_ sender: Any) {
        DispatchQueue.main.async {
            var contactsInfo = [Any]()
            
            contactsInfo.append("Пользователь CloudCards отправил Вам несколько контактов:")
            
            if self.selectedSectionIndex == 0 {
                self.selectedContacts.forEach { contact in
                    let idPair = IdPair(parentUuid: contact.user.parentId, uuid: contact.user.uuid)
                    guard let siteLink = generateSiteLink(with: idPair, isPersonal: true) else { return }
                    contactsInfo.append(siteLink)
                }
            } else {
                self.selectedCompanies.forEach { company in
                    let idPair = IdPair(parentUuid: company.parentUuid, uuid: company.uuid)
                    guard let siteLink = generateSiteLink(with: idPair, isPersonal: false) else { return }
                    contactsInfo.append(siteLink)
                }
            }
            
            let shareController = UIActivityViewController(activityItems: contactsInfo, applicationActivities: [])
            self.present(shareController, animated: true)
            
            self.cancelMultipleSelection()
        }
    }
    
    /*
        Метод, определяющий поведение кнопки множественного выбора контактов
     */

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

            self.navigationItem.rightBarButtonItem = cancelButton
        }
    }
    
    /*
        Метод, определяющий поведение UISegmentedControl
     */
    
    @objc func segmentItemChanged(_ segmentedControl: UISegmentedControl) {
        cancelMultipleSelection()
        selectedSectionIndex = segmentedControl.selectedSegmentIndex
        if selectedSectionIndex == 0 {
            self.navigationItem.searchController?.searchBar.scopeButtonTitles = ["Имя", "Фамилия", "Компания"]
            self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex = 0
        } else {
            self.navigationItem.searchController?.searchBar.scopeButtonTitles = nil
        }
        contactsTable.reloadData()
    }
    
    /*
        Метод загрузки данных
     */
    
    private func loadContacts() {
        // Устанавливаем здесь, поскольку при обновлении списка контактов сортировка устанавливается по фамилии
        field = .surname
        
        let userDictionary = realm.objects(User.self)
        let ownerUuid = userDictionary.count > 0 ? userDictionary[0].uuid : String()
        let idPairList = Array(realm.objects(IdPair.self).filter("parentUuid != \"\(ownerUuid)\""))
        if idPairList.count == 0 {
            loadingIndicator.stopAnimating()
            self.importFirstContactNotification.isHidden = false
        } else {
            self.importFirstContactNotification.isHidden = true
            getContactsFromDatabase(idPairList)
        }
    }
    
    /*
        Метод, отменяющий действия множественного выбора
     */

    private func cancelMultipleSelection() {
        setContactsMenu()
        selectedContacts.removeAll()
        selectedCompanies.removeAll()
        navigationController?.isToolbarHidden = true
        contactsTable.setEditing(false, animated: true)
    }
    
    /*
        Метод, устанавливающий кнопку меню
     */

    private func setContactsMenu() {
        let sortByNameAction = UIAction(title: "Имя") { (_) in
            sortContacts(in: self, by: .name)
            self.field = .name
            self.setContactsMenu()
        }
        
        let sortBySurnameAction = UIAction(title: "Фамилия") { (_) in
            sortContacts(in: self, by: .surname)
            self.field = .surname
            self.setContactsMenu()
        }
        
        let sortByCompanyAction = UIAction(title: "Компания") { (_) in
            sortContacts(in: self, by: .company)
            self.field = .company
            self.setContactsMenu()
        }
        
        let sortByJobTitleAction = UIAction(title: "Должность") { (_) in
            sortContacts(in: self, by: .jobTitle)
            self.field = .jobTitle
            self.setContactsMenu()
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
        
        let selectMultipleContacts = UIAction(title: "Выбрать", image: UIImage(systemName: "checkmark.circle")) { (_) in
            self.onMultipleSelectionButtonTap(self)
            self.navigationController?.isToolbarHidden = false
            setToolbar(for: self)
        }
        
        let scanBusinessCardAction = UIAction(title: "Сканировать\nвизитку", image: UIImage(systemName: "camera")) { (_) in
            let cameraController = self.storyboard?.instantiateViewController(withIdentifier: "CameraController") as! CameraController
            self.navigationController?.show(cameraController, sender: self)
        }
        
        let actionsSubmenu = UIMenu(title: String(), options: .displayInline, children: [selectMultipleContacts, scanBusinessCardAction])
        let sortSubmenu = UIMenu(title: String(), options: .displayInline, children: [sortByNameAction, sortBySurnameAction, sortByCompanyAction, sortByJobTitleAction])
        
        let menu = UIMenu(title: String(), children: [actionsSubmenu, sortSubmenu])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            menu: menu
        )
    }
    
    /*
        Метод, устанавливающий изображение галочки на выбранный тип сортировки
     */
    
    private func setCheckmarkForAction(action: UIAction) {
        action.setValue(UIImage(systemName: "checkmark"), forKey: "image")
    }
    
    /*
        Метод загрузки данных непосредственно из Firebase
     */
    
    private func getContactsFromDatabase(_ idPairList: [IdPair]) {
        companyCards.removeAll()
        var userCards = [Contact]()
        // Получение визитки с выбранными полями для каждой пары ID
        idPairList.forEach { idPair in
            FirebaseClientInstance.getInstance().getUser(idPair: idPair) { result in
                switch result {
                case .success(let data):
                    var userBoolean = UserBoolean()
                    let cardType = CardType(rawValue: data["type"] as? String ?? String())
                    switch cardType {
                    case .personal:
                        let businessCard = JsonUtils.convertFromDictionary(dictionary: data, type: BusinessCard<UserBoolean>.self)
                        userBoolean = businessCard.data
                    case .company:
                        let businessCard = JsonUtils.convertFromDictionary(dictionary: data, type: BusinessCard<Company>.self)
                        self.companyCards.append(businessCard.data)
                        self.checkForEndOfContactList(userCards, idPairList)
                        return
                    default:
                        userBoolean = JsonUtils.convertFromDictionary(dictionary: data, type: UserBoolean.self)
                    }
                    // Получение пользователя для структуры Контакт
                    let idPairMainUser = IdPair(parentUuid: idPair.parentUuid, uuid: idPair.parentUuid)
                    FirebaseClientInstance.getInstance().getUser(idPair: idPairMainUser, pathToData: true) { result in
                        switch result {
                        case .success(let data):
                            // Генерация конечного контакта для отображения
                            let parentUser = JsonUtils.convertFromDictionary(dictionary: data, type: User.self)
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

                            userCards.append(contact)
                            self.checkForEndOfContactList(userCards, idPairList)
                            
                        case .failure(let error):
                            print(error)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    /*
        Метод, определяющий поведение контроллера при окончательном считывании всех контактов
     */
    
    private func checkForEndOfContactList(_ userCards: [Contact], _ idPairList: [IdPair]) {
        if userCards.count + self.companyCards.count == idPairList.count {
            sortContacts(in: self, with: userCards, by: .surname)
            self.loadingIndicator.stopAnimating()
        }
    }
}

// MARK: - UITableViewDataSource

extension ContactsController: UITableViewDataSource {
    
    // Секции есть только в таблице с визитками людей
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedSectionIndex == 1 || searchIsActivated() ? 1 : contactsSectionTitles.count
    }
    
    // Проверка сначала на выбранный тип визиток, потом на активированную строку поиска
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSectionIndex == 0 {
            if searchIsActivated() {
                return selectedContacts.count
            }
            return contactsDictionary[contactsSectionTitles[section]]!.count
        }
        if searchIsActivated() {
            return selectedCompanies.count
        }
        return companyCards.count
    }
    
    // Проверка сначала на выбранный тип визиток, потом на активированную строку поиска
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedSectionIndex == 0 {
            let cell = contactsTable.dequeueReusableCell(withIdentifier: reuseIdentifierForContact, for: indexPath) as! ContactCell
            
            if searchIsActivated() {
                cell.update(with: selectedContacts[indexPath.row])
            } else {
                let contactKey = contactsSectionTitles[indexPath.section]
                if let contactValues = contactsDictionary[contactKey] {
                    cell.update(with: contactValues[indexPath.row])
                }
            }
            
            return cell
        }
        
        let cell = contactsTable.dequeueReusableCell(withIdentifier: reuseIdentifietForCompany, for: indexPath) as! CompanyCell
        if searchIsActivated() {
            cell.update(with: selectedCompanies[indexPath.row])
            return cell
        }
        
        cell.update(with: companyCards[indexPath.row])
        return cell
    }
    
    // Заголовки секций есть только в таблице с визитками людей
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedSectionIndex == 1 || searchIsActivated() ? nil : contactsSectionTitles[section]
    }
    
    // Оглавление секций есть только в таблице с визитками людей
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return selectedSectionIndex == 1 || searchIsActivated() ? nil : contactsSectionTitles
    }
}

// MARK: - UITableViewDelegate

extension ContactsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        if contactsTable.isEditing {
            if selectedSectionIndex == 0 {
                let contact = getContactFromRow(indexPath)
                selectedContacts.append(contact)
            } else {
                let company = getCompanyFromRow(indexPath)
                selectedCompanies.append(company)
            }

            cell.tintColor = UIColor(named: "Primary")
        } else {
            let cardViewController: CardViewController
            cardViewController = storyboard?.instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
            
            if selectedSectionIndex == 0 {
                cardViewController.currentUser = getContactFromRow(indexPath).user
            } else {
                cardViewController.currentCompany = getCompanyFromRow(indexPath)
            }
            
            let nav = UINavigationController(rootViewController: cardViewController)
            navigationController?.showDetailViewController(nav, sender: nil)
            contactsTable.deselectSelectedRows(animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let idPair = getIdPair(with: indexPath)
        
        if selectedSectionIndex == 0 {
            selectedContacts.removeAll(where: { $0.user.uuid == idPair.uuid })
        } else {
            selectedCompanies.removeAll(where: { $0.uuid == idPair.uuid })
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let qr = showQRAction(at: indexPath)
        let share = shareAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, share, qr])
    }
    
    private func getContactFromRow(_ indexPath: IndexPath) -> Contact {
        if searchIsActivated() {
            return selectedContacts[indexPath.row]
        }
        let contactKey = contactsSectionTitles[indexPath.section]
        let contactValues = contactsDictionary[contactKey]
        return contactValues![indexPath.row]
    }
    
    private func getCompanyFromRow(_ indexPath: IndexPath) -> Company {
        return companyCards[indexPath.row]
    }
}

// MARK: - RowButtons

extension ContactsController {
    
    func showQRAction(at indexPath: IndexPath) -> UIContextualAction {
        let idPair = getIdPair(with: indexPath)
        
        let action = UIContextualAction(style: .normal, title: "ShowQR") { (action, view, completion) in
            guard let url = generateSiteLink(with: idPair, isPersonal: self.isPersonalCard()) else { return }
            showShareController(with: url, in: self)
            completion(true)
        }
        action.image = UIImage(systemName: "qrcode")
        action.backgroundColor = UIColor(named: "Primary")
        
        return action
    }
    
    func shareAction(at indexPath: IndexPath) -> UIContextualAction {
        let idPair = getIdPair(with: indexPath)
        
        let action = UIContextualAction(style: .normal, title: "Share") { (action, view, completion) in
            guard let url = generateSiteLink(with: idPair, isPersonal: self.isPersonalCard()) else { return }
            showShareLinkController(with: url, in: self)
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
        let idPair = getIdPair(with: indexPath)
        
        try! realm.write {
            realm.delete(realm.objects(IdPair.self).filter("uuid == \"\(idPair.uuid)\""))
        }

        if selectedSectionIndex == 0 {
            // Удаляем контакт из словаря контактов
            let contactKey = contactsSectionTitles[indexPath.section]
            let contact = contactsDictionary[contactKey]?.first(where: { $0.user.uuid == idPair.uuid })
            contactsDictionary[contactKey]?.removeAll(where: { $0 == contact })
            
            // Удаляем ячейку таблицы с данным контактом
            contactsTable.deleteRows(at: [indexPath], with: .automatic)
            
            // Если на первую букву фамилии никого больше нет, то удаляем сначала букву из списка,
            // а уже после удаляем секцию в самой таблице, отображаемой на экране
            if !contactsDictionary[contactKey]!.contains(where: { $0.user.surname.prefix(1) == contact!.user.surname.prefix(1) }) {
                contactsSectionTitles.removeAll(where: { $0 == String(contact!.user.surname.prefix(1)) })
                let indexSet = IndexSet(arrayLiteral: indexPath.section)
                contactsTable.deleteSections(indexSet, with: .automatic)
            }
        } else {
            // Удаляем компанию из списка компаний
            companyCards.removeAll(where: { $0.uuid == idPair.uuid })
            
            // Удаляем ячейку таблицы с данной компанией
            contactsTable.deleteRows(at: [indexPath], with: .automatic)
        }
        
        
        importFirstContactNotification.isHidden = contactsSectionTitles.count != 0 || companyCards.count != 0
    }
    
    private func getIdPair(with indexPath: IndexPath) -> IdPair {
        if selectedSectionIndex == 0 {
            let contactUser = getContactFromRow(indexPath).user
            return IdPair(parentUuid: contactUser.parentId, uuid: contactUser.uuid)
        } else {
            let company = getCompanyFromRow(indexPath)
            return IdPair(parentUuid: company.parentUuid, uuid: company.uuid)
        }
    }
    
    // Получение информации о том, какую визитку пользователь хочет отправить
    private func isPersonalCard() -> Bool {
        return selectedSectionIndex == 0
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
            self.selectedContacts.removeAll()
            self.selectedCompanies.removeAll()
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
    
    // Если в разделе с контактами людей, то у нас есть доп. условие, по которому ищем, в компаниях ищем только по наименованию
    func updateSearchResults(with searchBar: UISearchBar, searchText: String) {
        if selectedSectionIndex == 0 {
            var contacts = [Contact]()
            let contactsArrays = self.contactsDictionary.values
            
            contactsArrays.forEach { users in
                contacts.append(contentsOf: users)
            }
            
            selectedContacts.removeAll()
            switch searchBar.selectedScopeButtonIndex {
            case 1:
                selectedContacts = contacts.filter({ contact -> Bool in
                    return contact.user.surname.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                })
            case 2:
                selectedContacts = contacts.filter({ contact -> Bool in
                    return contact.user.company.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                })
            default:
                selectedContacts = contacts.filter({ contact -> Bool in
                    return contact.user.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                })
            }
        } else {
            selectedCompanies.removeAll()
            selectedCompanies = companyCards.filter({ company -> Bool in
                return company.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
            print(selectedCompanies.count)
        }
        
        contactsTable.reloadData()
    }
    
    func searchIsActivated() -> Bool {
        return self.navigationItem.searchController!.isActive && self.navigationItem.searchController?.searchBar.text != ""
    }
}
