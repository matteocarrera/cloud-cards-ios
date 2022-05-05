import UIKit

private let reuseIdentifier = "TemplateCell"

class TemplatesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet var addTemplateButton: UIBarButtonItem!

    // Массив шаблонных карточек основного пользователя приложения
    public var templates = [Card]()
    private let realm = RealmInstance.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        setLargeNavigationBar(for: self)
        setAddTemplateButton()
        migrateContactsToIdPairs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        templates.removeAll()
        templates = Array(realm.objects(Card.self))

        collectionView.reloadData()
    }

    func openCreateTemplateWindow() {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "CreateCardController") as? CreateCardController else {
            return
        }
        let nav = UINavigationController(rootViewController: viewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

    func openCreateCompanyCardWindow() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "CreateCardCompanyController")
        let nav = UINavigationController(rootViewController: viewController!)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

    /*
        Миграция контактов в пары ID, доступно с версии 1.4
     */

    private func migrateContactsToIdPairs() {
        let userBooleanList = Array(realm.objects(UserBoolean.self))
        if !userBooleanList.isEmpty {
            userBooleanList.forEach {user in
                let idPair = IdPair(parentUuid: user.parentId, uuid: user.uuid)
                try? realm.write {
                    realm.add(idPair)
                    realm.delete(user)
                }
            }
        }
    }

    private func setAddTemplateButton() {
        let createPersonalCardAction = UIAction(
            title: "Личная визитка",
            image: UIImage(systemName: "person")
        ) { (_) in
            if self.realm.objects(User.self).count == 0 {
                showSimpleAlert(
                    withTitle: "Недоступно",
                    withMessage: "Создайте профиль для доступа к этой функции",
                    inController: self
                )
                return
            }
            self.openCreateTemplateWindow()
        }

        let createCompanyCardAction = UIAction(
            title: "Визитка компании",
            image: UIImage(systemName: "building.2")
        ) { (_) in
            if self.realm.objects(User.self).count == 0 {
                showSimpleAlert(
                    withTitle: "Недоступно",
                    withMessage: "Создайте профиль для доступа к этой функции",
                    inController: self
                )
                return
            }
            self.openCreateCompanyCardWindow()
        }

        let menu = UIMenu(title: String(), children: [createPersonalCardAction, createCompanyCardAction])

        let addTemplate: UIBarButtonItem = UIBarButtonItem(
            image: addTemplateButton.image,
            menu: menu
        )
        addTemplate.tintColor = UIColor(named: "Primary")
        navigationItem.leftBarButtonItem = addTemplate
    }

    private func openCreateCardSelectionMenu() {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)

        let createPersonalCardAction = UIAlertAction.init(title: "Личная визитка", style: .default, handler: { (_) in
            self.openCreateTemplateWindow()
        })
        createPersonalCardAction.setValue(UIImage(systemName: "person"), forKey: "image")

        let createCompanyCardAction = UIAlertAction.init(title: "Визитка компании", style: .default, handler: { (_) in
            self.openCreateCompanyCardWindow()
        })
        createCompanyCardAction.setValue(UIImage(systemName: "building.2"), forKey: "image")

        alert.addAction(createPersonalCardAction)
        alert.addAction(createCompanyCardAction)
        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == templates.count {
            if realm.objects(User.self).count == 0 {
                showSimpleAlert(
                    withTitle: "Недоступно",
                    withMessage: "Создайте профиль для доступа к этой функции",
                    inController: self
                )
                return
            }
            openCreateCardSelectionMenu()
            return
        }

        guard let cell = collectionView.cellForItem(at: indexPath) as? TemplateCell else {
            return
        }
        let idPair = IdPair(parentUuid: cell.parentUser.uuid, uuid: cell.templateCard.cardUuid)
        guard let url = generateSiteLink(with: idPair, isPersonal: cell.templateCard.type == CardType.personal.rawValue) else { return }

        showShareController(with: url, in: self)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TemplateCell else {
            return .init(frame: .init(x: 0, y: 0, width: 0, height: 0))
        }

        if indexPath.row == templates.count {
            cell.update(with: nil, in: self)
            return cell
        }

        cell.update(with: templates[indexPath.row], in: self)

        return cell
    }
}
