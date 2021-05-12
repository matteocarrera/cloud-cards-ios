import UIKit

private let reuseIdentifier = "DataCell"
private let reuseIdentifierCardParameters = "CardParametersCell"

class CreateCardController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var createProfileNotification: UILabel!
    
    private let realm = RealmInstance.getInstance()
    private let cardParameters = ["Название визитки", "ЦВЕТ"]
    private var cardTitle = String()
    // Массив данных пользователя: 1 элемент - 1 вид данных
    private var data = [DataItem]()
    // Массив выбранных данных пользователя для создания визитки
    private var selectedItems = [DataItem]()
    private var selectedColor = String()
    private var templateUserList = [UserBoolean]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        configureTableView(table: tableView, controller: self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifierCardParameters)
        tableView.setEditing(true, animated: true)
        setLargeNavigationBar(for: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cardTitle = String()
        selectedColor = COLORS[0]
        selectedItems.removeAll()
        getAllTemplateUsers()
        
        /*
            Получение данных пользователя
         */
        
        let userDictionary = realm.objects(User.self)
        if userDictionary.count != 0 {
            let owner = userDictionary[0]
            data = setDataToList(from: owner)
            createProfileNotification.isHidden = true
        } else {
            data = [DataItem]()
            createProfileNotification.isHidden = false
        }
        
        tableView.reloadData()
    }

    @IBAction func saveCardToTemplates(_ sender: Any) {
        let title = tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if selectedItems.count == 0 {
            showSimpleAlert(
                withTitle: "Данные не выбраны",
                withMessage: "Вы не выбрали ни одного поля!",
                inController: self
            )
            return
        }
        
        if !selectedItems.contains(where: { $0.title == "фамилия" }) ||
            !selectedItems.contains(where: { $0.title == "имя" }) {
            showSimpleAlert(
                withTitle: "Данные не выбраны",
                withMessage: "Визитка обязательно должна содержать Ваши имя и фамилию!",
                inController: self
            )
            return
        }
        
        if title == cardParameters[0] {
            showSimpleAlert(
                withTitle: "Название не указано",
                withMessage: "Введите название визитки!",
                inController: self
            )
            return
        }
        
        let cards = Array(realm.objects(Card.self))
        var titleForCardAlreadyExists = false
        cards.forEach { card in
            if card.title == title {
                titleForCardAlreadyExists = true
            }
        }
        if titleForCardAlreadyExists {
            showSimpleAlert(
                withTitle: "Название занято",
                withMessage: "Визитка с таким названием уже существует!",
                inController: self
            )
            return
        }
        
        saveCard(
            withTitle: cardTitle,
            withColor: selectedColor,
            withUserData: selectedItems,
            withTemplateUserList: templateUserList
        )
        // Получение TemplatesController (Nav -> Tab -> Nav -> Cards)
        navigationController?.presentingViewController?.children.first?.children.first?.viewWillAppear(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func showEnterCardNameAlert() {
        let alert = UIAlertController(title: "Имя визитки", message: "Введите имя визитки", preferredStyle: .alert)
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        
        alert.addTextField { (textField) in
            textField.autocapitalizationType = .sentences
            textField.clearButtonMode = .whileEditing
            textField.text = cell?.textLabel?.text == self.cardParameters[0] ? String() : cell?.textLabel?.text
        }

        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: { [weak alert] (_) in
            var cardName = alert?.textFields![0].text
            cell?.textLabel?.textColor = .label
            if cardName == String() {
                cardName = self.cardParameters[0]
                cell?.textLabel?.textColor = .secondaryLabel
            }
            cell?.textLabel?.text = cardName
            self.cardTitle = cardName!
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true, completion: nil)
    }
    
    private func getAllTemplateUsers() {
        let ownerUser = realm.objects(User.self)[0]
        let idPairList = realm.objects(IdPair.self).filter("parentUuid == \"\(ownerUser.parentId)\"")

        for idPair in idPairList {
            FirebaseClientInstance.getInstance().getUser(
                firstKey: idPair.parentUuid,
                secondKey: idPair.uuid,
                firstKeyPath: FirestoreInstance.USERS,
                secondKeyPath: FirestoreInstance.CARDS
            ) { result in
                switch result {
                case .success(let data):
                    let templateUser = JsonUtils.convertFromDictionary(dictionary: data, type: UserBoolean.self)
                    self.templateUserList.append(templateUser)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

extension CreateCardController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "СВОЙСТВА ВИЗИТКИ"
        } else if section == 1 {
            return "ДАННЫЕ ВИЗИТКИ"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return setCardParametersCell(for: indexPath)
        }
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! DataCell
        
        cell = cell.update(with: data[indexPath.row])

        let view = UIView()
        view.backgroundColor = .clear
        cell.selectedBackgroundView = view

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: false)
            if indexPath.row == 1 {
                selectedColor = COLORS[Int.random(in: 0..<COLORS.count)]
                cell.imageView?.tintColor = UIColor.init(hexString: selectedColor)
                return
            }
            showEnterCardNameAlert()
            return
        }
    
        let dataCell = data[indexPath.row]
    
        cell.tintColor = UIColor(named: "Primary")
        
        selectedItems.append(DataItem(title: dataCell.title, data: dataCell.data))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let dataCell = data[indexPath.row]
        selectedItems.removeAll(where: { $0.title == dataCell.title })
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    
    private func setCardParametersCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierCardParameters, for: indexPath)
        cell.textLabel?.text = cardTitle
        if cardTitle.isEmpty {
            cell.textLabel?.text = cardParameters[indexPath.row]
            cell.textLabel?.textColor = .secondaryLabel
            cell.backgroundColor = UIColor(named: "DataCellColor")
        }
        cell.selectionStyle = .none
        if indexPath.row == 1 {
            cell.textLabel?.text = cardParameters[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage.init(systemName: "square.fill")
            cell.imageView?.tintColor = UIColor.init(hexString: selectedColor)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 21.0, weight: .regular)
        }
        return cell
    }
}

extension CreateCardController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cardParameters.count
        }
        return data.count
    }
}
