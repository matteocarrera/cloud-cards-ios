import UIKit
import RealmSwift
import FirebaseDatabase

class QRController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var companyLabel: UILabel!
    @IBOutlet var jobTitleLabel: UILabel!
    @IBOutlet var mobileLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
    // ID пользователя, полученный при переходе в окно просмотра QR кода
    public var contact: UserBoolean?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ref = Database.database().reference().child(contact!.parentId).child(contact!.parentId)

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let json = snapshot.value as? String {

                let owner = convertFromJson(json: json, type: User.self)
                  
                let currentUser = getUserFromTemplate(user: owner, userBoolean: self.contact!)
                
                self.fullNameLabel.text = currentUser.surname + " " + currentUser.name + " " + currentUser.patronymic
                self.companyLabel.text = currentUser.company
                self.jobTitleLabel.text = currentUser.jobTitle
                self.mobileLabel.text = currentUser.mobile
                self.emailLabel.text = currentUser.email
             }
        })
        imageView.image = generateQR(userLink: contact!.parentId + "|" + contact!.uuid)
    }
}
