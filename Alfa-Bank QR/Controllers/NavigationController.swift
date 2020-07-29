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
        let statusBarColor = UIColor(red: 11, green: 31, blue: 53, alpha: 1)
        statusBarView.backgroundColor = statusBarColor
        self.view.addSubview(statusBarView)

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
