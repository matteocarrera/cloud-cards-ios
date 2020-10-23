import UIKit
import RealmSwift

class CardsController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var selectMultipleButton: UIBarButtonItem!
    @IBOutlet var addTemplateButton: UIBarButtonItem!
    @IBOutlet weak var templatesView: UIView!
    @IBOutlet weak var contactsView: UIView!
    
    private let realm = RealmInstance.getInstance()
    private var navigationBar = UINavigationBar()
    private var search = UISearchController()
    
    // Флаг, показывающий, что пользователь выбрал функцмножественного выбора визиток
    public var multipleChoiceActivated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar = self.navigationController!.navigationBar
        
        navigationBar.prefersLargeTitles = true
        
        setLargeNavigationBar()
        
        setSearchBar()
        
        // В данном случае Recognizer требуется для того, чтобы скрывать клавиатуру при нажатии на свободное место на экране
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Белый цвет текста для переключателя окон визиток
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: GRAPHITE ], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: GRAPHITE ], for: .normal)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Сделано для устранения бага с зависанием заголовка при переходе на просмотр визитки
        self.navigationItem.title = "Визитки"
        
        self.navigationItem.largeTitleDisplayMode = .always
        
        let contactsController = self.children[1] as! ContactsController
        contactsController.cancelSelection()
        
        self.navigationItem.leftBarButtonItem = nil
        multipleChoiceActivated = false

        setAddTemplateButton()
        
        indexChanged(segmentedControl)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Сделано для устранения бага с зависанием заголовка при переходе на просмотр визитки
        self.navigationItem.title = ""
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc func openCreateTemplateWindow(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "SelectDataController") as! SelectDataController
        self.navigationController?.pushViewController(viewController, animated: true)
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
            cancelButton.tintColor = PRIMARY

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
                self.navigationItem.leftBarButtonItem?.tintColor = PRIMARY
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            case 1:
                templatesView.isHidden = true
                contactsView.isHidden = false
                self.navigationItem.rightBarButtonItem?.tintColor = PRIMARY
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clear
                self.navigationItem.leftBarButtonItem?.isEnabled = false
            default:
                break;
        }
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
    
    // Добавляет строку поиска в NavBar
    private func setSearchBar() {
        search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Поиск"
        search.searchBar.setValue("Отмена", forKey: "cancelButtonText")
        self.navigationItem.searchController = search
    }
    
    private func setAddTemplateButton() {
        let addTemplate: UIBarButtonItem = UIBarButtonItem(
            image: addTemplateButton.image,
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(CardsController.openCreateTemplateWindow(_:))
        )
        addTemplate.tintColor = PRIMARY
        self.navigationItem.leftBarButtonItem = addTemplate

    }
}

extension CardsController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Поиск
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
