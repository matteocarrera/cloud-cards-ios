import UIKit
import FirebaseFirestore

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
        
        let db = FirestoreInstance.getInstance()
        db.collection("users").document(contact!.parentId).collection("data").document(contact!.parentId).getDocument {
            (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                
                let owner = convertFromDictionary(dictionary: dataDescription!, type: User.self)
                  
                let currentUser = getUserFromTemplate(user: owner, userBoolean: self.contact!)
                
                self.fullNameLabel.text = currentUser.surname + " " + currentUser.name + " " + currentUser.patronymic
                self.companyLabel.text = currentUser.company
                self.jobTitleLabel.text = currentUser.jobTitle
                self.mobileLabel.text = currentUser.mobile
                self.emailLabel.text = currentUser.email
            }
        }
        imageView.image = generateQR(userLink: contact!.parentId + "|" + contact!.uuid)
    }
}
