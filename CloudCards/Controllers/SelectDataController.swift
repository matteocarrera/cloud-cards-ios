import UIKit
import RealmSwift
import FirebaseFirestore

class SelectDataController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var createProfileNotification: UILabel!
    
    private let realm = RealmInstance.getInstance()
    
    // Массив данных пользователя: 1 элемент - 1 вид данных
    private var data = [DataItem]()
    // Массив выбранных данных пользователя для создания визитки
    private var selectedItems = [DataItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: tableView, controller: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedItems.removeAll()
        
        /*
            Получение данных пользователя
         */
        
        let userDictionary = realm.objects(User.self)
        if userDictionary.count != 0 {
            let owner = userDictionary[0]
            data = setDataToList(user: owner)
            createProfileNotification.isHidden = true
        } else {
            data = [DataItem]()
            createProfileNotification.isHidden = false
        }
        
        tableView.reloadData()
    }

    @IBAction func saveCardToTemplates(_ sender: Any) {
        if selectedItems.count != 0 {
            showSaveAlert()
        } else {
            showAlert()
        }
    }
    
    private func showSaveAlert() {
        let alert = UIAlertController(title: "Сохранение визитки", message: "Введите имя визитки", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.autocapitalizationType = .words
            textField.text = ""
        }

        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.saveUser(title: textField?.text)
            // Получение TemplatesController (Nav -> Tab -> Nav -> Cards -> Templates)
            self.navigationController?.presentingViewController?.children.first?.children.first?.children.first?.viewWillAppear(true)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
    
    private func saveUser(title : String?) {
        
        let ownerUser = realm.objects(User.self)[0]
        
        let newUser = parseDataToUserBoolean(data: selectedItems)
        newUser.parentId = ownerUser.parentId
        
        let userDictionary = realm.objects(UserBoolean.self)
        
        /*
            Делаем проверку на то, что визитка с выбранными полями уже существует
         */
        
        var userExists = false
        
        for user in userDictionary {
            if generatedUsersEqual(firstUser: newUser, secondUser: user) {
                newUser.uuid = user.uuid
                userExists = true
            }
        }
        
        if !userExists {
            let uuid = UUID().uuidString
            newUser.uuid = uuid
            
            let userData = convertToDictionary(someUser: newUser)
            
            let db = FirestoreInstance.getInstance()
            db.collection(FirestoreInstance.USERS)
                .document(newUser.parentId)
                .collection(FirestoreInstance.CARDS)
                .document(newUser.uuid)
                .setData(userData)

            try! realm.write {
                realm.add(newUser)
            }
        }
        
        /*
            Если мы вызываем метод для генерации QR без сохранения в шаблоны, то передаем QRView
            для последующего перехода в окно, демонстрирующее QR код на экране
         */
        
        let card = Card()
        card.color = COLORS[Int.random(in: 0..<COLORS.count)]
        card.title = title!
        card.userId = newUser.uuid
        
        let maxValue = realm.objects(Card.self).max(ofProperty: "id") as Int?
        if (maxValue != nil) {
            card.id = maxValue! + 1
        } else {
            card.id = 0
        }
        
        try! realm.write {
            realm.add(card)
        }
    }

    private func showAlert() {
        showSimpleAlert(controller: self, title: "Данные не выбраны", message: "Вы не выбрали ни одного поля!")
    }
}

extension SelectDataController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectDataCell", for: indexPath) as! SelectDataCell
        
        let dataCell = data[indexPath.row]
        cell.descriptionText?.text = dataCell.description
        cell.titleText?.text = dataCell.title
        
        if dataCell.isSelected {
            cell.buttonTick.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: UIControl.State.normal)
            cell.buttonTick.tintColor = PRIMARY
        } else {
            cell.buttonTick.setBackgroundImage(UIImage(systemName: "circle"), for: UIControl.State.normal)
            cell.buttonTick.tintColor = PRIMARY
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = data[indexPath.row]
        dataCell.isSelected = !dataCell.isSelected
        
        if !selectedItems.contains(where: { $0.title == dataCell.title }) {
            selectedItems.append(DataItem(title: dataCell.title, description: dataCell.description))
        } else {
            selectedItems.removeAll(where: { $0.title == dataCell.title })
        }
        
        tableView.reloadData()
    }
}

extension SelectDataController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
}

class SelectDataCell : UITableViewCell {
    
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var buttonTick: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
