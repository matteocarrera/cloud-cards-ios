import UIKit

private let reuseIdentifier = "DataCell"
private let reuseIdentifierCardParameters = "CardParametersCell"

class MyCardViewController: UITableViewController {
    
    @IBOutlet var cardDataTable: UITableView!
    
    public var currentCard = Card()
    public var currentUser = User()
    
    private let realm = RealmInstance.getInstance()
    private var data = [DataItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(closeWindow(_:))
        )
        backButton.tintColor = PRIMARY
        navigationItem.rightBarButtonItem = backButton
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifierCardParameters)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        data.removeAll()
        data = setDataToList(from: currentUser)
    }
    
    @objc func closeWindow(_ sender: Any) {
        // Получение TemplatesController (Nav -> Tab -> Nav -> Cards)
        self.navigationController?.presentingViewController?.children.first?.children.first?.viewWillAppear(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierCardParameters, for: indexPath)
            cell.textLabel?.text = currentCard.title
            cell.textLabel?.font = UIFont.systemFont(ofSize: 21.0, weight: .regular)
            cell.imageView?.image = UIImage.init(systemName: "square.fill")!
                .resized(toWidth: CGFloat(45))?
                .withTintColor(UIColor.init(hexString: currentCard.color))
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! DataCell

        let dataCell = data[indexPath.row]
        cell.titleLabel.text = dataCell.title
        cell.dataLabel.text = dataCell.data
        cell.selectionStyle = .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            showCardMenu()
        }
    }
    
    private func showCardMenu() {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let rename = UIAlertAction.init(title: "Переименовать", style: .default, handler: { (_) in
            self.showEnterCardNameAlert()
        })
        alert.addAction(rename)
        
        let changeColor = UIAlertAction.init(title: "Изменить цвет", style: .default, handler: { (_) in
            self.changeCardColor()
        })
        alert.addAction(changeColor)
        
        let delete = UIAlertAction.init(title: "Удалить визитку", style: .destructive, handler: { (_) in
            self.deleteCard()
        })
        alert.addAction(delete)
        
        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
            
        self.present(alert, animated: true)
    }
    
    private func showEnterCardNameAlert() {
        let alert = UIAlertController(title: "Имя визитки", message: "Введите имя визитки", preferredStyle: .alert)
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        
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
            cell?.textLabel?.text = cardName
            
            try! self.realm.write {
                self.currentCard.title = cardName
                
                self.realm.add(self.currentCard, update: .all)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        self.present(alert, animated: true, completion: nil)
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
    
    private func deleteCard() {
        let alert = UIAlertController(title: "Удаление визитки", message: "Вы действительно хотите удалить визитку?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { (_) in
            try! self.realm.write {
                self.realm.delete(self.currentCard)
            }
            self.closeWindow(self)
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
}
