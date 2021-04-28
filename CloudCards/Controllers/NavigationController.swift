import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBarView = UIView()
        let statusBarColor = UIColor(named: "NavigationBarColor")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
    }
}
