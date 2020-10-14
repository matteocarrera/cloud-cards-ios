import UIKit
import RealmSwift

class CardsController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var selectButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var templatesView: UIView!
    @IBOutlet weak var contactsView: UIView!
    
    private let realm = try! Realm()
    
    // Флаг, показывающий, что пользователь выбрал функцию множественного выбора визиток
    public var multipleChoiceActivated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Убирает нижнюю полосу у NavBar
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // В данном случае Recognizer требуется для того, чтобы скрывать клавиатуру при нажатии на свободное место на экране
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Белый цвет текста для переключателя окон визиток
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .normal)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let contactsController = self.children[1] as! ContactsController
        contactsController.cancelSelection()
        
        self.navigationItem.leftBarButtonItem = nil
        multipleChoiceActivated = false
        
        indexChanged(segmentedControl)
    }
    
    @objc func selectMultiple(_ sender: Any) {
        if multipleChoiceActivated {
            let contactsController = self.children[1] as! ContactsController
            contactsController.cancelSelection()
            self.navigationItem.leftBarButtonItem = nil
        } else {
            let cancelButton : UIBarButtonItem = UIBarButtonItem(
                title: "Отменить",
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(selectMultiple(_:))
            )
            cancelButton.tintColor = UIColor.white

            self.navigationItem.rightBarButtonItem = cancelButton
            
            multipleChoiceActivated = true
        }
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
