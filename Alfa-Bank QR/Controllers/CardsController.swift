import UIKit
import RealmSwift

class CardsController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var selectButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var templatesView: UIView!
    @IBOutlet weak var contactsView: UIView!
    
    private let realm = try! Realm()
    
    // Флаг, показывающий, что пользователь выбрал функцию множественного выбора визиток
    public var multipleChoiceActivated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // В данном случае Recognizer требуется для того, чтобы скрывать клавиатуру при нажатии на свободное место на экране
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .normal)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        shareButton.tintColor = UIColor(hexString: PRIMARY_DARK)
        shareButton.isEnabled = false
        
        multipleChoiceActivated = false
        
        indexChanged(segmentedControl)
    }
    
    @IBAction func selectMultiple(_ sender: Any) {
        if multipleChoiceActivated {
            cancelSelection()
        } else {
            let cancelButton : UIBarButtonItem = UIBarButtonItem(title: "Отменить", style: UIBarButtonItem.Style.plain, target: self, action: #selector(selectMultiple(_:)))
            cancelButton.tintColor = UIColor.white

            self.navigationItem.rightBarButtonItem = cancelButton
            
            multipleChoiceActivated = true
            shareButton.tintColor = UIColor(hexString: WHITE)
            shareButton.isEnabled = true
        }
    }
    
    /*
        TODO("Сделать отправку ссылок на визитку пользователя, не QR кода")
     */
    
    @IBAction func openMenu(_ sender: Any) {
        let alert = UIAlertController.init(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)
        
        let contactsController = self.children[1] as! ContactsController
        
        alert.addAction(UIAlertAction.init(title: "Поделиться", style: .default, handler: { (_) in
            var images = [UIImage]()
            for contactLink in contactsController.selectedContactsUuid {
                let image = generateQR(userLink: contactLink)
                images.append(image!)
            }
            
            let shareController = UIActivityViewController(activityItems: images, applicationActivities: [])
            self.present(shareController, animated: true)
            
            self.cancelSelection()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Удалить", style: .default, handler: { (_) in
            for uuid in contactsController.selectedContactsUuid {
                let userUuid = uuid.split(separator: "|")[1]
                
                let contact = self.realm.objects(UserBoolean.self).filter("uuid = \"\(userUuid)\"")[0]
                
                try! self.realm.write {
                    self.realm.delete(contact)
                }
            }
            
            self.cancelSelection()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
            
        self.present(alert, animated: true)
        
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                templatesView.isHidden = false
                contactsView.isHidden = true
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            case 1:
                templatesView.isHidden = true
                contactsView.isHidden = false
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            default:
                break;
        }
    }
    
    private func cancelSelection() {
        let child = children[1] as! ContactsController
        
        let select : UIBarButtonItem = UIBarButtonItem(image: selectButton.image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(selectMultiple(_:)))
        select.tintColor = UIColor.white

        self.navigationItem.rightBarButtonItem = select
        
        child.viewWillAppear(true)
        multipleChoiceActivated = false
        shareButton.tintColor = UIColor(hexString: PRIMARY_DARK)
        shareButton.isEnabled = false
    }
    
}

extension CardsController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
