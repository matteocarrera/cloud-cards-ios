//
//  ProgramUtils.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 31.07.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

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
        } else if title == "email" || title == "email (другой)" {
            if let url = URL(string: "mailto:\(description)") {
              UIApplication.shared.openURL(url)
            }
        } else if title == "адрес" || title == "адрес (другой)"{
            openMaps(address: description)
        } else if title == "сайт" {
            guard let url = URL(string: "http://\(description)") else { return }
            UIApplication.shared.openURL(url)
        } else if title == "vk" {
            guard let url = URL(string: "http://vk.com/\(description)") else { return }
            UIApplication.shared.openURL(url)
            //openApp(site: title, userLink: description)
        } else if title == "facebook" {
            openApp(site: title, userLink: description)
        } else if title == "twitter" {
            openApp(site: title, userLink: description)
        } else if title == "instagram" {
            openApp(site: title, userLink: description)
        } else {
            UIPasteboard.general.string = description
            showAlert(title: title, controller: controller)
        }
    }
    
    private static func openApp(site : String, userLink : String) {
        let hooks = getHooksAndUrl(site: site)[0]
        let siteUrl = getHooksAndUrl(site: site)[1]
        let appUrl = NSURL(string: hooks)
        if UIApplication.shared.canOpenURL(appUrl! as URL) {
            UIApplication.shared.openURL(appUrl! as URL)
        } else {
          //redirect to safari because the user doesn't have an app
            UIApplication.shared.openURL(NSURL(string: siteUrl + userLink)! as URL)
        }
    }
    
    static func openMaps(address : String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarksOptional, error) -> Void in
          if let placemarks = placemarksOptional {
            print("placemark| \(String(describing: placemarks.first))")
            if let location = placemarks.first?.location {
              let query = "?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)"
              let path = "http://maps.apple.com/" + query
              if let url = NSURL(string: path) {
                UIApplication.shared.openURL(url as URL)
              } else {
                // Could not construct url. Handle error.
              }
            } else {
              // Could not get a location from the geocode request. Handle error.
            }
          } else {
            // Didn't get any placemarks. Handle error.
          }
        }
    }
    
    private static func getHooksAndUrl(site : String) -> [String] {
        var data: Array<String> = Array(repeating: "", count: 2)
        if site == "instagram" {
            data[0] = "instagram://user?username="
            data[1] = "http://instagram.com/"
        } else if site == "facebook" {
            data[0] = "fb://profile/"
            data[1] = "http://facebook.com/"
        } else if site == "twitter" {
            data[0] = "twitter://user?screen_name="
            data[1] = "http://twitter.com/"
        } else {
            //data[0] = "vkontakte://profile/"
            //data[1] = "http://vk.com/"
        }
        return data
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
