import UIKit
import RealmSwift

class TemplatesController: UIViewController {

    @IBOutlet weak var templatesTable: UITableView!
    @IBOutlet var createFirstTemplateNotification: UILabel!
    @IBOutlet var addTemplateButton: UIBarButtonItem!
    
    private let realm = RealmInstance.getInstance()
    
    // Массив шаблонных карточек основного пользователя приложения
    private var templates = [Card]()
    private var navigationBar = UINavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: templatesTable, controller: self)
        
        navigationBar = self.navigationController!.navigationBar
        navigationBar.prefersLargeTitles = true
        
        setLargeNavigationBar()
        setAddTemplateButton()
        
        viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Сделано для устранения бага с зависанием заголовка при переходе на просмотр визитки
        self.navigationItem.title = "Визитки"
        self.navigationItem.largeTitleDisplayMode = .always
        
        templates.removeAll()
        templates = Array(realm.objects(Card.self))
        
        createFirstTemplateNotification.isHidden = templates.count != 0
        
        getImportedCard()
        
        templatesTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Сделано для устранения бага с зависанием заголовка при переходе на просмотр визитки
        self.navigationItem.title = ""
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc func openCreateTemplateWindow() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "SelectDataController") as! SelectDataController
        let nav = UINavigationController(rootViewController: viewController)
        self.navigationController?.showDetailViewController(nav, sender: nil)
    }
    
    // Добавляет стиль для большого варианта NavBar
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
    
    private func setAddTemplateButton() {
        let addTemplate: UIBarButtonItem = UIBarButtonItem(
            image: addTemplateButton.image,
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(openCreateTemplateWindow)
        )
        addTemplate.tintColor = PRIMARY
        self.navigationItem.leftBarButtonItem = addTemplate
    }
    
    /*
        Получение импортированных визиток в приложение и их обработка и сохранение
     */
    
    private func getImportedCard() {
        let defaults = UserDefaults(suiteName: "group.com.mksdevelopmentgroup.cloudcards")
        let link = String((defaults?.string(forKey: "link") ?? ""))
        
        if link.contains("|") {
            saveUser(controller: self, link: link)
        }

        defaults?.removeObject(forKey: "link")
    }
}

extension TemplatesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = templatesTable.dequeueReusableCell(withIdentifier: "TemplatesDataCell", for: indexPath) as! TemplatesDataCell
        
        let dataCell = templates[indexPath.row]
        cell.title.text = dataCell.title
        cell.color.backgroundColor = UIColor(hexString: dataCell.color)
        cell.userId = dataCell.userId
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = templates[indexPath.row]

        let templateUser = self.realm.objects(UserBoolean.self).filter("uuid = \"\(dataCell.userId)\"")[0]
        let parentUser = self.realm.objects(User.self)[0]
        let generatedUser = getUserFromTemplate(user: parentUser, userBoolean: templateUser)
        
        let qrController = self.storyboard?.instantiateViewController(withIdentifier: "QRController") as! QRController
        qrController.contact = generatedUser
        
        self.navigationController?.pushViewController(qrController, animated: true)

        templatesTable.reloadData()
    }
}

extension TemplatesController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let open = openTemplate(at: indexPath)
        let share = shareTemplate(at: indexPath)
        let delete = deleteTemplate(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, share, open])
    }
    
    func openTemplate(at indexPath: IndexPath) -> UIContextualAction {
        let card = templates[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Open Template") { (action, view, completion) in
            
            let templateUser = self.realm.objects(UserBoolean.self).filter("uuid = \"\(card.userId)\"")[0]
            let parentUser = self.realm.objects(User.self)[0]
            let generatedUser = getUserFromTemplate(user: parentUser, userBoolean: templateUser)
            
            let cardViewController = self.storyboard?.instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
            cardViewController.currentUser = generatedUser
            self.navigationController?.pushViewController(cardViewController, animated: true)
            
            completion(true)
        }
        action.image = UIImage(systemName: "person.fill")
        action.backgroundColor = PRIMARY
        return action
    }
    
    func shareTemplate(at indexPath: IndexPath) -> UIContextualAction {
        let card = templates[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Share") { (action, view, completion) in
            
            let owner = self.realm.objects(User.self)[0]
            let userLink = "\(owner.uuid)|\(card.userId)"

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
    
    func deleteTemplate(at indexPath: IndexPath) -> UIContextualAction {
        let card = templates[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            try! self.realm.write {
                self.realm.delete(card)
            }
            
            self.templates.remove(at: indexPath.row)
            self.templatesTable.deleteRows(at: [indexPath], with: .automatic)

            completion(true)
        }
        action.image = UIImage(systemName: "trash")
        return action
    }
}

class TemplatesDataCell : UITableViewCell {
    
    @IBOutlet weak var color : UIView!
    @IBOutlet weak var title : UILabel!
    var userId : String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setColorToSelectedRow(tableCell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
