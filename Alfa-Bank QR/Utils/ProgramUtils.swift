//
//  ProgramUtils.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 31.07.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation
import UIKit

class ProgramUtils {
        
    static func generateQR(userLink : String) -> UIImage? {
        let data = userLink.data(using: String.Encoding.utf8)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        
        return UIImage.init(ciImage: scaledQrImage)
    }
    
    static func performAction(title : String, description : String, controller : UIViewController) {
        if title == "мобильный номер" || title == "мобильный номер (другой)" {
            if let url = NSURL(string: "tel://\(description)"), UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.openURL(url as URL)
            }
        } else {
            UIPasteboard.general.string = description
            showAlert(title: title, controller: controller)
        }
    }
    
    private static func showAlert(title : String, controller : UIViewController) {
        let alert = UIAlertController(title: "", message: "Данные поля \"\(title)\" успешно скопированы!", preferredStyle: .alert)
        controller.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
          alert.dismiss(animated: true, completion: nil)
        }
    }
}
