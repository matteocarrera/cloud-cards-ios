import Foundation
import UIKit
import CoreLocation
import Contacts

func showSimpleAlert(controller : UIViewController, title : String, message : String) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    controller.present(ac, animated: true)
}

func generateQR(userLink : String) -> UIImage? {
    let data = userLink.data(using: String.Encoding.utf8)
    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    qrFilter.setValue(data, forKey: "inputMessage")
    guard let qrImage = qrFilter.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledQrImage = qrImage.transformed(by: transform)
    
    return UIImage.init(ciImage: scaledQrImage)
}

func performActionWithField(title : String, description : String, controller : UIViewController) {
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
        //guard let url = URL(string: "http://vk.com/\(description)") else { return }
        //UIApplication.shared.openURL(url)
        openApp(site: title, userLink: description)
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

func exportToContacts(user : User, photo : UIImage?, controller : UIViewController) {
    
    var contactExists = false
    
    let contactStore = CNContactStore()
    var contacts = [CNContact]()
    let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactPhoneNumbersKey,
                CNContactEmailAddressesKey] as [Any]
    let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
    
    do {
        try contactStore.enumerateContacts(with: request) { (contact, stop) in contacts.append(contact)
            for phoneNumber in contact.phoneNumbers {
                if let number = phoneNumber.value as? CNPhoneNumber {
                    if cleanPhoneNumber(number: user.mobile) == cleanPhoneNumber(number: number.stringValue) ||
                        cleanPhoneNumber(number: user.mobileSecond) == cleanPhoneNumber(number: number.stringValue) {
                        contactExists = true
                    }
                    //print(cleanPhoneNumber(number: number.stringValue))
                }
            }
        }
    } catch {
        print("Невозможно получить список контактов")
    }
    
    if contactExists {
        showSimpleAlert(controller: controller, title: "Контакт существует!", message: "Такой контакт уже существует!")
        return
    }
    
    let contact = CNMutableContact()

    if photo != nil {
        contact.imageData = photo?.jpegData(compressionQuality: 1.0)
    }

    if user.name != "" {
        contact.givenName = user.name
    }
    
    if user.surname != "" {
        contact.familyName = user.surname
    }
    
    if user.patronymic != "" {
        contact.middleName = user.patronymic
    }
    
    if user.company != "" {
        contact.organizationName = user.company
    }
    
    if user.jobTitle != "" {
        contact.jobTitle = user.jobTitle
    }
    
    if user.mobile != "" {
        contact.phoneNumbers.append(CNLabeledValue(
        label: CNLabelPhoneNumberMain,
        value: CNPhoneNumber(stringValue: user.mobile)))
    }
    
    if user.mobileSecond != "" {
        contact.phoneNumbers.append(CNLabeledValue(
        label: CNLabelPhoneNumberMobile,
        value: CNPhoneNumber(stringValue: user.mobileSecond)))
    }
    
    if user.email != "" {
        contact.emailAddresses.append(CNLabeledValue(
        label: CNLabelWork,
        value: user.email as NSString))
    }
    
    if user.emailSecond != "" {
        contact.emailAddresses.append(CNLabeledValue(
        label: CNLabelOther,
        value: user.emailSecond as NSString))
    }

    if user.address != "" {
        let address = CNMutablePostalAddress()
        address.street = user.address
        
        contact.postalAddresses.append(CNLabeledValue(
        label: CNLabelWork,
        value: address))
    }
    
    if user.addressSecond != "" {
        let addressSecond = CNMutablePostalAddress()
        addressSecond.street = user.addressSecond
        
        contact.postalAddresses.append(CNLabeledValue(
        label: CNLabelOther,
        value: addressSecond))
    }
    
    // Пропущены номера карт
    
    if user.website != "" {
        contact.urlAddresses.append(CNLabeledValue(
        label: CNLabelWork,
        value: user.website as NSString))
    }
    
    // Пропущен вк
    
    if user.facebook != "" {
        contact.socialProfiles.append(CNLabeledValue(label: "Facebook", value: CNSocialProfile(urlString: "https://www.facebook.com/" + user.facebook, username: user.facebook, userIdentifier: user.facebook, service: CNSocialProfileServiceFacebook)))
    }
    
    if user.twitter != "" {
        contact.socialProfiles.append(CNLabeledValue(label: "Twitter", value: CNSocialProfile(urlString: "https://www.twitter.com/" + user.twitter, username: user.twitter, userIdentifier: user.twitter, service: CNSocialProfileServiceTwitter)))
    }
    
    // Пропущен инстаграм и телеграм
    
    if user.notes != "" {
        contact.note = user.notes
    }

    let store = CNContactStore()
    let saveRequest = CNSaveRequest()
    saveRequest.add(contact, toContainerWithIdentifier: nil)

    do {
        try store.execute(saveRequest)
        
        let alert = UIAlertController(title: "Успешно", message: "Контакт успешно экспортирован!", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "ОК", style: .cancel))
        controller.present(alert, animated: true, completion: nil)
        
    } catch {
        print("Ошибка сохранения контакта, ошибка: \(error)")
    }

}

private func openApp(site : String, userLink : String) {
    let hooks = getHooksAndUrl(site: site)[0]
    let siteUrl = getHooksAndUrl(site: site)[1]
    let appUrl = NSURL(string: hooks)
    if UIApplication.shared.canOpenURL(appUrl! as URL) {
        UIApplication.shared.openURL(appUrl! as URL)
    } else {
        UIApplication.shared.openURL(NSURL(string: siteUrl + userLink)! as URL)
    }
}

private func openMaps(address : String) {
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
                    print("Невозможно создать URL")
                }
            } else {
                print("Невозможно получить расположение по геокоду")
            }
        } else {
            print("Не было получено ни одной точки")
        }
    }
}

private func getHooksAndUrl(site : String) -> [String] {
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
        data[0] = "vk://vk.com/"
        data[1] = "http://vk.com/"
    }
    return data
}

private func showAlert(title : String, controller : UIViewController) {
    let alert = UIAlertController(title: "", message: "Данные поля \"\(title)\" успешно скопированы!", preferredStyle: .alert)
    controller.present(alert, animated: true, completion: nil)

    let when = DispatchTime.now() + 1
    DispatchQueue.main.asyncAfter(deadline: when){
      alert.dismiss(animated: true, completion: nil)
    }
}

private func cleanPhoneNumber(number : String) -> String {
    if number != "" {
        var cleanNumber = number
            .replacingOccurrences(of: "+", with: "", options: NSString.CompareOptions.literal, range: nil)
            .replacingOccurrences(of: "(", with: "", options: NSString.CompareOptions.literal, range: nil)
            .replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
            .replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
            .replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        cleanNumber.remove(at: cleanNumber.startIndex)
        return cleanNumber
    } else {
        return ""
    }
}
