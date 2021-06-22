import UIKit
import RealmSwift

class ContactsController: UIViewController {

    @IBOutlet var contactsTable: UITableView!
    @IBOutlet var importFirstContactNotification: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    public var contactsSectionTitles = [String]()
    public var contactsDictionary = [String:[User]]()
    private let realm = RealmInstance.getInstance()
    private var companyCards = [Company]()
    private var selectedUsers = [User]()
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
        
        loadBusinessCards()
        loadingIndicator.stopAnimating()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        cancelMultipleSelection()
        setContactsMenu()
    }
    
    /*
        Метод, позволяющий обновить содержимое таблицы
     */
    
    @objc func refreshTable(_ sender: Any) {
        loadBusinessCards()
        contactsTable.refreshControl?.endRefreshing()
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
        shareMultipleBusinessCards(from: self, sectionIndex: selectedSectionIndex, users: selectedUsers, companies: selectedCompanies)
        cancelMultipleSelection()
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
            let cancelButton: UIBarButtonItem = UIBarButtonItem(
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
        Метод, отменяющий действия множественного выбора
     */

    private func cancelMultipleSelection() {
        setContactsMenu()
        selectedUsers.removeAll()
        selectedCompanies.removeAll()
        navigationController?.isToolbarHidden = true
        contactsTable.setEditing(false, animated: true)
    }
    
    /*
        Метод, устанавливающий кнопку меню
     */

    private func setContactsMenu() {
        let sortByNameAction = UIAction(title: "Имя") { (_) in
            sortUsers(in: self, by: .name)
            self.field = .name
            self.setContactsMenu()
        }
        
        let sortBySurnameAction = UIAction(title: "Фамилия") { (_) in
            sortUsers(in: self, by: .surname)
            self.field = .surname
            self.setContactsMenu()
        }
        
        let sortByCompanyAction = UIAction(title: "Компания") { (_) in
            sortUsers(in: self, by: .company)
            self.field = .company
            self.setContactsMenu()
        }
        
        let sortByJobTitleAction = UIAction(title: "Должность") { (_) in
            sortUsers(in: self, by: .jobTitle)
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
        Метод загрузки отсканированных карточек
     */
    
    private func loadBusinessCards() {
        DispatchQueue.global().async {
            let realm = try! Realm()
            let userDictionary = realm.objects(User.self)
            let ownerUuid = !userDictionary.isEmpty ? userDictionary[0].uuid : String()
            let idPairList = Array(realm.objects(IdPair.self).filter("parentUuid != \"\(ownerUuid)\""))
            if idPairList.isEmpty {
                DispatchQueue.main.async {
                    self.importFirstContactNotification.isHidden = false
                    self.contactsTable.reloadData()
                }
                return
            }
            
            FirestoreInstance.getBusinessCards(idPairList) { result in
                switch result {
                case .success(let (users, companies)):
                    sortUsers(in: self, with: users, by: self.field)
                    self.companyCards = companies
                    
                    DispatchQueue.main.async {
                        self.contactsTable.reloadData()
                    }
                    break
                case .failure(let error):
                    print(error)
                }
            }
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
                return selectedUsers.count
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
            let cell = contactsTable.dequeueReusableCell(withIdentifier: ContactCell.reuseIdentifier, for: indexPath) as! ContactCell
            
            if searchIsActivated() {
                cell.update(with: selectedUsers[indexPath.row])
            } else {
                let contactKey = contactsSectionTitles[indexPath.section]
                if let contactValues = contactsDictionary[contactKey] {
                    cell.update(with: contactValues[indexPath.row])
                }
            }
            
            return cell
        }
        
        let cell = contactsTable.dequeueReusableCell(withIdentifier: CompanyCell.reuseIdentifier, for: indexPath) as! CompanyCell
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
                let user = getContactFromRow(indexPath)
                selectedUsers.append(user)
            } else {
                let company = getCompanyFromRow(indexPath)
                selectedCompanies.append(company)
            }

            cell.tintColor = UIColor(named: "Primary")
        } else {
            let cardViewController: CardViewController
            cardViewController = storyboard?.instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
            
            if selectedSectionIndex == 0 {
                cardViewController.currentUser = getContactFromRow(indexPath)
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
            selectedUsers.removeAll(where: { $0.uuid == idPair.uuid })
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
    
    private func getContactFromRow(_ indexPath: IndexPath) -> User {
        if searchIsActivated() {
            return selectedUsers[indexPath.row]
        }
        let contactKey = contactsSectionTitles[indexPath.section]
        let contactValues = contactsDictionary[contactKey]
        return contactValues![indexPath.row]
    }
    
    private func getCompanyFromRow(_ indexPath: IndexPath) -> Company {
        return searchIsActivated() ? selectedCompanies[indexPath.row] : companyCards[indexPath.row]
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
            shareBusinessCard(with: url, in: self)
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
            let contact = contactsDictionary[contactKey]?.first(where: { $0.uuid == idPair.uuid })
            contactsDictionary[contactKey]?.removeAll(where: { $0 == contact })
            
            // Удаляем ячейку таблицы с данным контактом
            contactsTable.deleteRows(at: [indexPath], with: .automatic)
            
            // Если на первую букву фамилии никого больше нет, то удаляем сначала букву из списка,
            // а уже после удаляем секцию в самой таблице, отображаемой на экране
            if !contactsDictionary[contactKey]!.contains(where: { $0.surname.prefix(1) == contact!.surname.prefix(1) }) {
                contactsSectionTitles.removeAll(where: { $0 == String(contact!.surname.prefix(1)) })
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
            let contactUser = getContactFromRow(indexPath)
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
        cancelMultipleSelection()
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.selectedUsers.removeAll()
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
            var allUsers = [User]()
            let contactsArrays = contactsDictionary.values

            contactsArrays.forEach { users in
                allUsers.append(contentsOf: users)
            }

            selectedUsers.removeAll()
            switch searchBar.selectedScopeButtonIndex {
            case 1:
                selectedUsers = allUsers.filter({ user -> Bool in
                    return user.surname.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                })
            case 2:
                selectedUsers = allUsers.filter({ user -> Bool in
                    return user.company.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                })
            default:
                selectedUsers = allUsers.filter({ user -> Bool in
                    return user.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                })
            }
        } else {
            selectedCompanies.removeAll()
            selectedCompanies = companyCards.filter({ company -> Bool in
                return company.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
        }

        contactsTable.reloadData()
    }
    
    func searchIsActivated() -> Bool {
        return self.navigationItem.searchController!.isActive && self.navigationItem.searchController?.searchBar.text != ""
    }
}
