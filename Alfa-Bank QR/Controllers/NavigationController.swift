//
//  NavigationController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 30.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

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
