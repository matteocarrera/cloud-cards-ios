import Foundation
import UIKit

class TemplateCell : UICollectionViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var plusImage: UIImageView!
    @IBOutlet var moreButton: UIButton!
    
    public var templateUser = UserBoolean()
    
    private var controller = TemplatesController()
    private var userId = String()
    private var cardId = 0
    private var parentUser = User()
    private let realm = RealmInstance.getInstance()
    
    public func update(with card: Card?, in parentController: TemplatesController) {
        setMenu()
        controller = parentController

        layer.cornerRadius = 15
        
        if card == nil {
            title.text = "Создать визитку"
            title.textColor = UIColor(named: "Primary")
            plusImage.isHidden = false
            moreButton.isHidden = true
            contentView.backgroundColor = UIColor(named: "CreateTemplateColor")
            return
        }
        
        title.text = card?.title
        title.textColor = .white
        userId = card!.userId
        cardId = card!.id
        contentView.backgroundColor = UIColor.init(hexString: card!.color)
        plusImage.isHidden = true
        moreButton.isHidden = false
        getCurrentCardUser()
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
            self.deleteCard()
        }
        
        let menu = UIMenu(title: String(), children: [info, share, delete])
        
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    private func openCard() {
        let currentUser = getUserFromTemplate(user: parentUser, userBoolean: templateUser)
        let currentCard = realm.objects(Card.self).filter("id == \(cardId)")[0]
        
        let myCardViewController = controller.storyboard?.instantiateViewController(withIdentifier: "MyCardViewController") as! MyCardViewController
        myCardViewController.currentUser = currentUser
        myCardViewController.currentCard = currentCard
        let nav = UINavigationController(rootViewController: myCardViewController)
        controller.navigationController?.showDetailViewController(nav, sender: nil)
    }
    
    private func shareCard() {
        let currentUser = getUserFromTemplate(user: parentUser, userBoolean: templateUser)
        showShareLinkController(with: currentUser, in: controller)
    }
    
    private func deleteCard() {
        // Удаляем карту из массива карт в родительском контроллере
        let card = self.realm.objects(Card.self).filter("id == \(self.cardId)")[0]
        let cardIndex = self.controller.templates.firstIndex(of: card)!
        self.controller.templates.remove(at: cardIndex)
        
        // Удаляем плитку карты в CollectionView
        let collectionView = self.superview as? UICollectionView
        let indexPath = collectionView?.indexPath(for: self)
        collectionView?.deleteItems(at: [indexPath!])

        // Удаляем карту из БД
        try! realm.write {
            let card = realm.objects(Card.self).filter("id == \(cardId)")[0]
            realm.delete(card)
        }
    }
    
    private func getCurrentCardUser() {
        parentUser = realm.objects(User.self)[0]
        let idPair = realm.objects(IdPair.self).filter("uuid = \"\(userId)\"")[0]
        FirebaseClientInstance.getInstance().getUser(
            firstKey: idPair.parentUuid,
            secondKey: idPair.uuid,
            firstKeyPath: FirestoreInstance.USERS,
            secondKeyPath: FirestoreInstance.CARDS
        ) { result in
            switch result {
            case .success(let data):
                self.templateUser = JsonUtils.convertFromDictionary(dictionary: data, type: UserBoolean.self)
            case .failure(let error):
                print(error)
            }
        }
    }
}
