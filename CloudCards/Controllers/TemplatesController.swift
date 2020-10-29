import UIKit
import RealmSwift

class TemplatesController: UIViewController {

    @IBOutlet weak var templatesTable: UITableView!
    @IBOutlet var createFirstTemplateNotification: UILabel!
    
    private let realm = RealmInstance.getInstance()
    
    // Массив шаблонных карточек основного пользователя приложения
    private var templates = [Card]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView(table: templatesTable, controller: self)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPressGestureRecognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        templates.removeAll()

        templates = Array(realm.objects(Card.self))
        
        if templates.count != 0 {
            createFirstTemplateNotification.isHidden = true
        } else {
            createFirstTemplateNotification.isHidden = false
        }
        
        /*
            Получение импортированных визиток в приложение и их обработка и сохранение
         */
        
        let defaults = UserDefaults(suiteName: "group.com.mksdevelopmentgroup.cloudcards")
        let link = String((defaults?.string(forKey: "link") ?? ""))
        
        if link.contains("|") {
            saveUser(controller: self, link: link)
        }

        defaults?.removeObject(forKey: "link")
        
        templatesTable.reloadData()
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let index = self.templatesTable.indexPathForRow(at: touchPoint)  {
                let card = templates[index.row]
                //showCardMenu(card: card)
            }
        }
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

        let contact = self.realm.objects(UserBoolean.self).filter("uuid = \"\(dataCell.userId)\"")[0]
        
        let qrController = self.storyboard?.instantiateViewController(withIdentifier: "QRController") as! QRController
        qrController.contact = contact
        
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
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
            viewController.userId = card.userId
            self.navigationController?.pushViewController(viewController, animated: true)
            
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
            let userLink = owner.uuid + "|" + card.userId

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
            //self.viewWillAppear(true)
            
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
