import UIKit
import RealmSwift
import FirebaseDatabase

class SelectDataController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var createProfileNotification: UILabel!
    
    private let realm = try! Realm()
    
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
    
    @IBAction func generateQR(_ sender: Any) {
        if selectedItems.count != 0 {
            saveUser(segue: "QRView", title: nil)
        } else {
            showAlert()
        }
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
            textField.text = ""
        }

        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.saveUser(segue: "", title: textField?.text)
            self.tabBarController?.selectedIndex = 0
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
    
    private func saveUser(segue : String, title : String?) {
        
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
            
            let ref = Database.database().reference()
            
            let json = convertToJson(someUser: newUser)
            
            ref.child(newUser.parentId).child(newUser.uuid).setValue(json)
            
            try! realm.write {
                realm.add(newUser)
            }
        }
        
        /*
            Если мы вызываем метод для генерации QR без сохранения в шаблоны, то передаем QRView
            для последующего перехода в окно, демонстрирующее QR код на экране
         */
        
        if (segue == "QRView") {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "QRController") as! QRController
            viewController.userLink = newUser.parentId + "|" + newUser.uuid
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
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
    }

    private func showAlert() {
        showSimpleAlert(controller: self, title: "Данные не выбраны", message: "Вы не выбрали ни одного поля!")
    }
}

extension SelectDataController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectDataCell", for: indexPath) as! SelectDataCell
        
        let dataCell = data[indexPath.row]
        cell.descriptionText?.text = dataCell.description
        cell.titleText?.text = dataCell.title
        
        if dataCell.isSelected
        {
            if #available(iOS 13.0, *) {
                cell.buttonTick.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: UIControl.State.normal)
            } else {
                cell.accessoryType = .checkmark
            }
        }
        else
        {
            if #available(iOS 13.0, *) {
                cell.buttonTick.setBackgroundImage(UIImage(systemName: "circle"), for: UIControl.State.normal)
            } else {
                cell.accessoryType = .none
            }
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

extension SelectDataController: UITableViewDelegate {}

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
