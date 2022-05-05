import UIKit

class TemplateCell: UICollectionViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var plusImage: UIImageView!
    @IBOutlet var moreButton: UIButton!

    public var parentUser = User()
    public var templateCard = Card()

    private var controller = TemplatesController()
    private let realm = RealmInstance.getInstance()

    public func update(with card: Card?, in parentController: TemplatesController) {
        setMenu()
        controller = parentController
        if card != nil {
            parentUser = realm.objects(User.self)[0]
        }

        layer.cornerRadius = 15

        if card == nil {
            title.text = "Создать визитку"
            title.textColor = UIColor(named: "Primary")
            plusImage.image = UIImage(systemName: "plus.circle.fill")
            plusImage.tintColor = UIColor(named: "Primary")
            moreButton.isHidden = true
            contentView.backgroundColor = UIColor(named: "CreateTemplateColor")
            return
        }

        templateCard = card!
        title.text = card?.title
        title.textColor = .white
        contentView.backgroundColor = UIColor.init(hexString: card!.color)
        plusImage.tintColor = .white
        if templateCard.type == CardType.company.rawValue {
            plusImage.image = UIImage(systemName: "building.2.crop.circle")
        } else {
            plusImage.image = UIImage(systemName: "person.crop.circle")
        }
        moreButton.isHidden = false
    }

    private func setMenu() {
        let info = UIAction(
            title: "Просмотреть",
            image: UIImage(systemName: "info.circle")
        ) { (_) in
            self.openCard()
        }

        let share = UIAction(
            title: "Поделиться",
            image: UIImage(systemName: "square.and.arrow.up")
        ) { (_) in
            self.shareCard()
        }

        let delete = UIAction(
            title: "Удалить",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { (_) in
            if self.templateCard.type == CardType.company.rawValue {
                let alert = UIAlertController(
                    title: "Удаление компании",
                    message: "Удаляя визитку компании, Вы полностью теряете к ней доступ! Люди, имеющие визитку с Вашей компанией, смогут продолжить её использование.",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Удалить", style: .destructive, handler: { (_) in
                    self.deleteCard()
                }))
                alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
                self.controller.present(alert, animated: true, completion: nil)
                return
            }
            self.deleteCard()
        }

        let menu = UIMenu(title: String(), children: [info, share, delete])

        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }

    private func openCard() {
        guard let myCardViewController =
                controller
                    .storyboard?
                    .instantiateViewController(withIdentifier: "MyCardViewController") as? MyCardViewController else {
            return
        }
        myCardViewController.currentCard = templateCard
        let nav = UINavigationController(rootViewController: myCardViewController)
        controller.navigationController?.showDetailViewController(nav, sender: nil)
    }

    private func shareCard() {
        let idPair = IdPair(parentUuid: parentUser.uuid, uuid: templateCard.cardUuid)
        guard let url = generateSiteLink(with: idPair,
                                         isPersonal: templateCard.type == CardType.personal.rawValue) else {
            return
        }
        shareBusinessCard(with: url, in: controller)
    }

    private func deleteCard() {
        // Удаляем карту из массива карт в родительском контроллере
        let cardIndex = self.controller.templates.firstIndex(of: templateCard)!
        self.controller.templates.remove(at: cardIndex)

        // Удаляем плитку карты в CollectionView
        let collectionView = self.superview as? UICollectionView
        let indexPath = collectionView?.indexPath(for: self)
        collectionView?.deleteItems(at: [indexPath!])

        // Удаляем карту из БД
        try? realm.write {
            realm.delete(templateCard)
        }
    }
}
