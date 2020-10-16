import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBarView = UIView()
        let statusBarColor = UIColor.init(hexString: PRIMARY_DARK)
        statusBarView.backgroundColor = statusBarColor
        self.view.addSubview(statusBarView)
    }
}
