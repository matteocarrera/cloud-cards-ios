import UIKit

class QRController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var companyLabel: UILabel!
    @IBOutlet var jobTitleLabel: UILabel!
    @IBOutlet var mobileLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
    // ID пользователя, полученный при переходе в окно просмотра QR кода
    public var contact = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.fullNameLabel.text = contact.surname + " " + contact.name + " " + contact.patronymic
        self.companyLabel.text = contact.company
        self.jobTitleLabel.text = contact.jobTitle
        self.mobileLabel.text = contact.mobile
        self.emailLabel.text = contact.email
        
        imageView.image = generateQR(userLink: contact.parentId + "|" + contact.uuid)
    }
}
