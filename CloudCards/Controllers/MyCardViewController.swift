import UIKit

class MyCardViewController: UITableViewController {

    @IBOutlet var cardDataTable: UITableView!

    public var currentCard = Card()

    private let realm = RealmInstance.getInstance()
    private var data = [DataItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CardParametersCell")
        isModalInPresentation = true
        data.removeAll()
        let ownerUser = realm.objects(User.self)[0]
        let idPair = IdPair(parentUuid: ownerUser.uuid, uuid: currentCard.cardUuid)
        FirebaseClientInstance.getInstance().getUser(idPair: idPair) { result in
            switch result {
            case .success(let data):
                let cardType = CardType(rawValue: data["type"] as? String ?? String())
                switch cardType {
                case .company:
                    let businessCard = JsonUtils.convertFromDictionary(dictionary: data, type: BusinessCard<Company>.self)
                    self.data = setCompanyDataToList(from: businessCard.data)
                case .personal:
                    let businessCard = JsonUtils.convertFromDictionary(dictionary: data, type: BusinessCard<UserBoolean>.self)
                    let currentUser = getUserFromTemplate(user: ownerUser, userBoolean: businessCard.data)
                    self.data = setDataToList(from: currentUser)
                default:
                    let businessCardUser = JsonUtils.convertFromDictionary(dictionary: data, type: UserBoolean.self)
                    let currentUser = getUserFromTemplate(user: ownerUser, userBoolean: businessCardUser)
                    self.data = setDataToList(from: currentUser)
                }
                self.cardDataTable.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    @IBAction func onReadyButtonTap(_ sender: Any) {
        // Получение TemplatesController (Nav -> Tab -> Nav -> Cards)
        navigationController?.presentingViewController?.children.first?.children.first?.viewWillAppear(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1 : data.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 0) ? CGFloat(75) : CGFloat(55)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CardParametersCell", for: indexPath)
            cell.textLabel?.text = currentCard.title
            cell.textLabel?.font = UIFont.systemFont(ofSize: 21.0, weight: .regular)
            cell.imageView?.image = UIImage.init(systemName: "square.fill")!
                .resized(toWidth: CGFloat(45))?
                .withTintColor(UIColor.init(hexString: currentCard.color))
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        var cell = tableView.dequeueReusableCell(withIdentifier: DataCell.reuseIdentifier, for: indexPath) as! DataCell
        cell = cell.update(with: data[indexPath.row])
        cell.selectionStyle = .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            showCardMenu()
            tableView.deselectSelectedRows(animated: true)
        }
    }

    private func showCardMenu() {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)

        if currentCard.type == CardType.personal.rawValue {
            let rename = UIAlertAction.init(title: "Переименовать", style: .default, handler: { (_) in
                self.showEnterCardNameAlert()
            })
            alert.addAction(rename)

            let changeColor = UIAlertAction.init(title: "Изменить цвет", style: .default, handler: { (_) in
                self.changeCardColor()
            })
            alert.addAction(changeColor)
        } else {
            let edit = UIAlertAction.init(title: "Редактировать", style: .default, handler: { (_) in
                self.editBusinessCard()
            })
            alert.addAction(edit)
        }

        let delete = UIAlertAction.init(title: "Удалить визитку", style: .destructive, handler: { (_) in
            if self.currentCard.type == CardType.company.rawValue {
                let alert = UIAlertController(
                    title: "Удаление компании",
                    message: "Удаляя визитку компании, Вы полностью теряете к ней доступ! Люди, имеющие визитку с Вашей компанией, смогут продолжить её использование.",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Удалить", style: .destructive, handler: { (_) in
                    self.deleteCard()
                }))
                alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.deleteCard()
        })
        alert.addAction(delete)

        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }

    private func showEnterCardNameAlert() {
        let alert = UIAlertController(title: "Имя визитки", message: "Введите имя визитки", preferredStyle: .alert)
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))

        alert.addTextField { (textField) in
            textField.autocapitalizationType = .sentences
            textField.clearButtonMode = .whileEditing
            textField.text = cell?.textLabel?.text
        }

        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: { [weak alert] (_) in
            guard let cardName = alert?.textFields![0].text else { return }
            if cardName == String() {
                showSimpleAlert(
                    withTitle: "Ошибка",
                    withMessage: "Имя визитки не может быть пустым",
                    inController: self
                )
                return
            }

            let cardNameList = self.realm.objects(Card.self).map { $0.title }
            if cardName != self.currentCard.title && cardNameList.contains(cardName) {
                showSimpleAlert(
                    withTitle: "Название занято",
                    withMessage: "Визитка с таким названием уже существует!",
                    inController: self
                )
                return
            }

            cell?.textLabel?.text = cardName

            try! self.realm.write {
                self.currentCard.title = cardName

                self.realm.add(self.currentCard, update: .all)
            }
        }))

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true, completion: nil)
    }

    private func changeCardColor() {
        var color = currentCard.color
        while color == currentCard.color {
            color = COLORS[Int.random(in: 0..<COLORS.count)]
        }

        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cell?.imageView?.image = cell?.imageView?.image?.withTintColor(UIColor.init(hexString: color))

        try! realm.write {
            currentCard.color = color

            realm.add(currentCard, update: .all)
        }
    }

    private func editBusinessCard() {
        let createCardCompanyController = storyboard?.instantiateViewController(withIdentifier: "CreateCardCompanyController") as! CreateCardCompanyController
        createCardCompanyController.templateCard = currentCard
        let nav = UINavigationController(rootViewController: createCardCompanyController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

    private func deleteCard() {
        let alert = UIAlertController(title: "Удаление визитки", message: "Вы действительно хотите удалить визитку?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { (_) in
            try! self.realm.write {
                self.realm.delete(self.currentCard)
            }
            self.onReadyButtonTap(self)
        }))

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true, completion: nil)
    }
}
