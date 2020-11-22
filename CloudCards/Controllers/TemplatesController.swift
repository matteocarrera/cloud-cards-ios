import UIKit

private let reuseIdentifier = "TemplateCell"

class TemplatesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var addTemplateButton: UIBarButtonItem!
    
    // Массив шаблонных карточек основного пользователя приложения
    public var templates = [Card]()
    
    private let realm = RealmInstance.getInstance()
    private var navigationBar = UINavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar = self.navigationController!.navigationBar
        navigationBar.prefersLargeTitles = true
        
        setLargeNavigationBar()
        setAddTemplateButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        templates.removeAll()
        templates = Array(realm.objects(Card.self))

        collectionView.reloadData()
        
        getImportedCard()
    }
    
    @objc func openCreateTemplateWindow() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "SelectDataController") as! SelectDataController
        let nav = UINavigationController(rootViewController: viewController)
        self.navigationController?.showDetailViewController(nav, sender: nil)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == templates.count {
            openCreateTemplateWindow()
            return
        }
        
        let templateUser = realm.objects(UserBoolean.self).filter("uuid = \"\(templates[indexPath.row].userId)\"")[0]
        let parentUser = realm.objects(User.self)[0]
        let generatedUser = getUserFromTemplate(user: parentUser, userBoolean: templateUser)
        let userLink = "\(generatedUser.parentId)|\(generatedUser.uuid)"
        
        showShareController(with: userLink, in: self)
    }
}

// MARK: - UICollectionViewDataSource

extension TemplatesController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  50
        let collectionViewSize = collectionView.frame.size.width - padding

        return CGSize(width: collectionViewSize/2, height: collectionViewSize/3)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TemplateCell
        
        if indexPath.row == templates.count {
            cell.update(with: nil, in: self)
            return cell
        }
        
        cell.update(with: templates[indexPath.row], in: self)
        
        return cell
    }
}
