//
//  SecondViewController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 16.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myString = "Всем привет!"
        let data = myString.data(using: String.Encoding.utf8)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        
        imageView.image = UIImage.init(ciImage: scaledQrImage)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

}

