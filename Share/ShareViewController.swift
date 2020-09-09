//
//  ShareViewController.swift
//  Share
//
//  Created by Владимир Макаров on 06.09.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import MobileCoreServices
import Social

class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //textView.isHidden = true
        textView.text = "Рекомендовано делать импорт с полностью закрытым приложением!"
        textView.tintColor = UIColor.clear
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Импортировать"
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = "Отмена"
    }
    
    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType = kUTTypeData as String
        for provider in attachments {
          if provider.hasItemConformingToTypeIdentifier(contentType) {
            provider.loadItem(forTypeIdentifier: contentType,
                              options: nil) { [unowned self] (data, error) in
            guard error == nil else { return }
                 
            if let url = data as? URL,
               let imageData = try? Data(contentsOf: url) {
                
                let qr = self.detectQRCode(UIImage(data: imageData))?.first as! CIQRCodeFeature
                let link = String(qr.messageString!)
                
                let defaults = UserDefaults(suiteName: "group.urfusoftware.Alfa-Bank-QR")
                defaults?.set(link, forKey: "link")
                
            } else {
              fatalError("Impossible to save image")
            }
          }}
        }
        
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return []
    }
    
    private func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features

        }
        return nil
    }
}
