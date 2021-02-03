import Foundation
import UIKit

class ContactCell: UITableViewCell {
    
    @IBOutlet var contactPhoto: UIImageView!
    @IBOutlet var contactName: UILabel!
    @IBOutlet var contactCompany: UILabel!
    @IBOutlet var contactJobTitle: UILabel!
    @IBOutlet var contactInitials: UILabel!

    public func update(with contact: Contact) {
        contactPhoto.layer.cornerRadius = contactPhoto.frame.height / 2
        
        contactName.text = "\(contact.user.name) \(contact.user.surname)"
        contactCompany.text = contact.user.company != String() ? contact.user.company : "Компания не указана"
        contactJobTitle.text = contact.user.jobTitle != String() ? contact.user.jobTitle : "Должность не указана"

        if contact.image != nil {
            contactPhoto.image = contact.image
            contactInitials.isHidden = true
        } else {
            contactPhoto.image = nil
            contactInitials.isHidden = false
            contactInitials.text = String(contact.user.name.character(at: 0)!) + String(contact.user.surname.character(at: 0)!)
        }
    }
}
