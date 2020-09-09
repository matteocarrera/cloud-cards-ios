//
//  QRController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 31.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit

class QRController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var userLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        imageView.image = ProgramUtils.generateQR(userLink: userLink)
    }
}
