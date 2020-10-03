import UIKit

class QRController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    public var userLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        imageView.image = ProgramUtils.generateQR(userLink: userLink)
    }
}
