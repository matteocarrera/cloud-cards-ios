import Foundation
import UIKit

class TemplateCell : UICollectionViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var plusImage: UIImageView!
    @IBOutlet var moreButton: UIButton!
    
    private var controller = TemplatesController()
    private var userId = String()
    private var cardId = 0
    
    private let realm = RealmInstance.getInstance()
    
    public func update(with card: Card?, in parentController: TemplatesController) {
        setMenu()
        controller = parentController

        layer.cornerRadius = 15
        
        if card == nil {
            title.text = "Создать визитку"
            title.textColor = PRIMARY
            plusImage.isHidden = false
            moreButton.isHidden = true
            contentView.backgroundColor = PRIMARY_10
            return
        }
        
        title.text = card?.title
        title.textColor = .white
        userId = card!.userId
        cardId = card!.id
        contentView.backgroundColor = UIColor.init(hexString: card!.color)
        plusImage.isHidden = true
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
            self.deleteCard()
        }
        
        let menu = UIMenu(title: String(), children: [info, share, delete])
        
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    private func openCard() {
        let currentUser = getCurrentCardUser()
        let currentCard = realm.objects(Card.self).filter("id == \(cardId)")[0]
        
        let myCardViewController = controller.storyboard?.instantiateViewController(withIdentifier: "MyCardViewController") as! MyCardViewController
        myCardViewController.currentUser = currentUser
        myCardViewController.currentCard = currentCard
        let nav = UINavigationController(rootViewController: myCardViewController)
        controller.navigationController?.showDetailViewController(nav, sender: nil)
    }
    
    private func shareCard() {
        let currentUser = getCurrentCardUser()
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
    
    private func getCurrentCardUser() -> User {
        let parentUser = realm.objects(User.self)[0]
        let templateUser = realm.objects(UserBoolean.self).filter("uuid = \"\(userId)\"")[0]
        return getUserFromTemplate(user: parentUser, userBoolean: templateUser)
    }
}
