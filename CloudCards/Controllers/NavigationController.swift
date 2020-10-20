import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBarView = UIView()
        let statusBarColor = LIGHT_GRAY
        statusBarView.backgroundColor = statusBarColor
        self.view.addSubview(statusBarView)
    }
}
