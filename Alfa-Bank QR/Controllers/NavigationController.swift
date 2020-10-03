import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBarView = UIView()
        let statusBarColor = UIColor.init(hexString: primaryDark)
        statusBarView.backgroundColor = statusBarColor
        self.view.addSubview(statusBarView)

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
