import Foundation
import UIKit

class TemplateCell : UICollectionViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var plusImage: UIImageView!
    @IBOutlet var moreButton: UIButton!
    
    public var userId = String()
    public var cardId = 0
    
    private let realm = RealmInstance.getInstance()
    
    @IBAction func moreButtonClicked(_ sender: Any) {
        try! realm.write {
            let card = realm.objects(Card.self).filter("id == \(cardId)")[0]
            card.color = COLORS[Int.random(in: 0..<COLORS.count)]
            
            realm.add(card, update: .all)
        }
        
        let collectionView = self.superview as? UICollectionView
        collectionView?.reloadData()
    }
}
