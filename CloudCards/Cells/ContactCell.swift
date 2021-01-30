import Foundation
import UIKit

class ContactCell: UITableViewCell {
    
    @IBOutlet var contactPhoto: UIImageView!
    @IBOutlet var contactName: UILabel!
    @IBOutlet var contactCompany: UILabel!
    @IBOutlet var contactJobTitle: UILabel!
    @IBOutlet var contactInitials: UILabel!
    private let firebaseClient = FirebaseClientInstance.getInstance()
    
    public func update(with user: User) {
        firebaseClient.getPhoto(with: user.photo) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.contactPhoto.image = image
                    self.contactInitials.isHidden = true
                case .failure(let error):
                    print(error)
                    self.contactInitials.isHidden = false
                    self.contactInitials.text = String(user.name.character(at: 0)!) + String(user.surname.character(at: 0)!)
                }
            }
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
