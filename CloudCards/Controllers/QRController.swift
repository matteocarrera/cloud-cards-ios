import UIKit

class QRController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    // ID пользователя, полученный при переходе в окно просмотра QR кода
    public var userLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        imageView.image = generateQR(userLink: userLink)
    }
}
