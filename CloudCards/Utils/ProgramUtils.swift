import Foundation
import UIKit
import CoreLocation
import Contacts

/*
    Простой Alert, содержащий в себе заголовок и текст
 */

public func showSimpleAlert(
    withTitle title: String,
    withMessage message: String,
    inController controller: UIViewController
) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    controller.present(ac, animated: true)
}

/*
    Alert без кнопки, но появляющийся на определенное количество секунд
 */

public func showTimeAlert(
    withTitle title: String,
    withMessage message: String,
    showForSeconds seconds: Double,
    inController controller: UIViewController
) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    controller.present(alert, animated: true, completion: nil)

    let when = DispatchTime.now() + seconds
    DispatchQueue.main.asyncAfter(deadline: when){
      alert.dismiss(animated: true, completion: nil)
    }
}

/*
    Вызов контроллера Поделиться, содержащего в себе ссылку на визитку пользователя на сайте
 */

public func showShareLinkController(with user: User, in controller: UIViewController) {
    let shareInfo = "\(user.name) \(user.surname) отправил(а) Вам свою визитку! Просмотрите её по ссылке:"
    guard let siteLink = generateSiteLink(with: user) else { return }
    
    let vc = UIActivityViewController(activityItems: [shareInfo, siteLink], applicationActivities: [])
    controller.present(vc, animated: true)
}

/*
    Нижняя шторка - контроллер Поделиться
 */

public func showShareController(with user: User, in controller: UIViewController) {
    let shareController = ShareController()
    shareController.modalPresentationStyle = .custom
    shareController.transitioningDelegate = controller as? UIViewControllerTransitioningDelegate
    shareController.user = user
    controller.present(shareController, animated: true, completion: nil)
}

/*
    Генерация QR-кода с предоставленным текстом
 */

public func generateQR(with userLink: String) -> UIImage? {
    let qrLink = "http://www.cloudcards.h1n.ru/#\(userLink)"
    let data = qrLink.data(using: String.Encoding.utf8)
    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    qrFilter.setValue(data, forKey: "inputMessage")
    guard let qrImage = qrFilter.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledQrImage = qrImage.transformed(by: transform)
    
    return UIImage.init(ciImage: scaledQrImage)
}

/*
    Генерация ссылки на визитку контакта
 */

public func generateSiteLink(with user: User) -> URL? {
    let link = "http://www.cloudcards.h1n.ru/#\(user.parentId)\(ID_SEPARATOR)\(user.uuid)"
    return URL(string: link) ?? nil
}

/*
    Большой NavigationBar для контроллера
 */

public func setLargeNavigationBar(for controller: UIViewController) {
    controller.navigationController!.navigationBar.prefersLargeTitles = true
    controller.navigationController?.view.backgroundColor = LIGHT_GRAY
    
    let appearance = UINavigationBarAppearance()
    appearance.backgroundColor = LIGHT_GRAY
    appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

    controller.navigationController!.navigationBar.compactAppearance = appearance
    controller.navigationController!.navigationBar.standardAppearance = appearance
    controller.navigationController!.navigationBar.scrollEdgeAppearance = appearance
}

/*
    Выполнение определенного действия, зависящего от предоставленных параметров
 */

public func performActionWithField(title: String, description: String, controller: UIViewController) {
    switch title {
    case MOBILE,
         MOBILE_OTHER:
        if let url = NSURL(string: "tel://\(description)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL, options: .init(), completionHandler: nil)
        }
    case EMAIL,
         EMAIL_OTHER:
        if let url = URL(string: "mailto:\(description)") {
            UIApplication.shared.open(url as URL, options: .init(), completionHandler: nil)
        }
    case ADDRESS,
         ADDRESS_OTHER:
        openMaps(address: description)
    case WEBSITE:
        guard let url = URL(string: "http://\(description)") else { return }
        UIApplication.shared.open(url as URL, options: .init(), completionHandler: nil)
    case VK,
         FACEBOOK,
         TWITTER,
         INSTAGRAM:
        openApp(site: title, userLink: description)
    default:
        UIPasteboard.general.string = description
        showTimeAlert(
            withTitle: String(),
            withMessage: "Данные поля \"\(title)\" успешно скопированы!",
            showForSeconds: 1,
            inController: controller
        )
    }
}


/*
    Экспорт контакта в контактную книжку телефона пользователя
 */

public func exportToContacts(user: User, photo: UIImage?, controller: UIViewController) {
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
                    if cleanPhoneNumber(user.mobile) == cleanPhoneNumber(number.stringValue) ||
                        cleanPhoneNumber(user.mobileSecond) == cleanPhoneNumber(number.stringValue) {
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
        showSimpleAlert(
            withTitle: "Контакт существует!",
            withMessage: "Такой контакт уже существует!",
            inController: controller
        )
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

/*
    Функция открытия приложения с предоставленными параметрами
 */

private func openApp(site: String, userLink: String) {
    let hooks = getHooksAndUrl(site: site)[0]
    let siteUrl = getHooksAndUrl(site: site)[1]
    let appUrl = NSURL(string: hooks)
    if UIApplication.shared.canOpenURL(appUrl! as URL) {
        UIApplication.shared.open(appUrl! as URL, options: .init(), completionHandler: nil)
    } else {
        UIApplication.shared.open(NSURL(string: siteUrl + userLink)! as URL, options: .init(), completionHandler: nil)
    }
}

/*
    Открытие карт с указанным адресом
 */

private func openMaps(address: String) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { (placemarksOptional, error) -> Void in
      
        if let placemarks = placemarksOptional {
            print("placemark| \(String(describing: placemarks.first))")
        
            if let location = placemarks.first?.location {
                let query = "?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)"
                let path = "http://maps.apple.com/" + query
                
                if let url = NSURL(string: path) {
                    UIApplication.shared.open(url as URL, options: .init(), completionHandler: nil)
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

/*
    Функция, возвращающая параметры приложения для его открытия
 */

private func getHooksAndUrl(site: String) -> [String] {
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

private func cleanPhoneNumber(_ number: String) -> String {
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
