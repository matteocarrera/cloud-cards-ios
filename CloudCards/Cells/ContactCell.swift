import UIKit

class ContactCell: UITableViewCell {
    
    public static let reuseIdentifier = "ContactCell"
    
    @IBOutlet var contactPhoto: UIImageView!
    @IBOutlet var contactName: UILabel!
    @IBOutlet var contactCompany: UILabel!
    @IBOutlet var contactJobTitle: UILabel!
    @IBOutlet var contactInitials: UILabel!
    
    public func update(with user: User) {
        contactPhoto.layer.cornerRadius = contactPhoto.frame.height / 2
        
        contactName.text = "\(user.name) \(user.surname)"
        contactCompany.text = user.company != String() ? user.company : "Компания не указана"
        contactJobTitle.text = user.jobTitle != String() ? user.jobTitle : "Должность не указана"
        
        FirebaseClientInstance.getInstance().getPhoto(setImageTo: contactPhoto, with: user.photo) { result in
            switch result {
            case .success(_):
                self.contactInitials.isHidden = true
            case .failure(let error):
                self.contactPhoto.image = nil
                self.contactInitials.isHidden = false
                self.contactInitials.text = String(user.name.character(at: 0)!) + String(user.surname.character(at: 0)!)
                //print("Job failed: \(error.localizedDescription)")
            }
        }
    }
}
