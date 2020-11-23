import Foundation
import UIKit

class ContactCell: UITableViewCell {
    
    @IBOutlet var contactPhoto: UIImageView!
    @IBOutlet var contactName: UILabel!
    @IBOutlet var contactCompany: UILabel!
    @IBOutlet var contactJobTitle: UILabel!
    @IBOutlet var contactInitials: UILabel!
    
    public func update(with user: User) {
        contactPhoto.image = getPhotoFromDatabase(photoUuid: user.photo)
        contactInitials.isHidden = true
        if contactPhoto.image == nil {
            contactInitials.isHidden = false
            contactInitials.text = String(user.name.character(at: 0)!) + String(user.surname.character(at: 0)!)
        }
        contactPhoto.layer.cornerRadius = contactPhoto.frame.height/2
          
        contactName.text = "\(user.name) \(user.surname)"
        
        if user.company != "" {
            contactCompany.text = user.company
        }
        
        if user.jobTitle != "" {
            contactJobTitle.text = user.jobTitle
        }
    }
}
