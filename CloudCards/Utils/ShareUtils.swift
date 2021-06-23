import UIKit

/*
    Вызов контроллера Поделиться, содержащего в себе ссылку на визитку пользователя на сайте
 */

public func shareBusinessCard(with url: URL, in controller: UIViewController) {
    let shareInfo = "Пользователь CloudCards отправил Вам визитку:"
    
    let shareController = UIActivityViewController(activityItems: [shareInfo, url], applicationActivities: [])
    controller.present(shareController, animated: true)
}

/*
    Поделиться несколькими визитками
 */

public func shareMultipleBusinessCards(
    from controller: UIViewController,
    sectionIndex selectedSectionIndex: Int,
    users selectedUsers: [User],
    companies selectedCompanies: [Company]
) {
    var contactsInfo = [Any]()
    
    contactsInfo.append("Пользователь CloudCards отправил Вам несколько визиток:")
    
    if selectedSectionIndex == 0 {
        selectedUsers.forEach { user in
            let idPair = IdPair(parentUuid: user.parentId, uuid: user.uuid)
            guard let siteLink = generateSiteLink(with: idPair, isPersonal: true) else { return }
            contactsInfo.append(siteLink)
        }
    } else {
        selectedCompanies.forEach { company in
            let idPair = IdPair(parentUuid: company.parentUuid, uuid: company.uuid)
            guard let siteLink = generateSiteLink(with: idPair, isPersonal: false) else { return }
            contactsInfo.append(siteLink)
        }
    }
    
    let shareController = UIActivityViewController(activityItems: contactsInfo, applicationActivities: [])
    controller.present(shareController, animated: true)
}

/*
    Генерация QR-кода с предоставленным текстом
 */

public func generateQR(with url: URL) -> UIImage? {
    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    qrFilter.setValue(url.dataRepresentation, forKey: "inputMessage")
    guard let qrImage = qrFilter.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledQrImage = qrImage.transformed(by: transform)
    
    let colorParameters = [
        "inputColor0": CIColor(color: UITraitCollection.current.userInterfaceStyle == .dark ? UIColor.white : UIColor.black), // Foreground
        "inputColor1": CIColor(color: UIColor.clear) // Background
    ]
    let coloredQrImage = scaledQrImage.applyingFilter("CIFalseColor", parameters: colorParameters)
    
    return UIImage.init(ciImage: coloredQrImage)
}

/*
    Генерация ссылки на визитку контакта
 */

public func generateSiteLink(with idPair: IdPair, isPersonal: Bool) -> URL? {
    let type = isPersonal ? CardType.personal.rawValue : CardType.company.rawValue
    let linkBody = "\(idPair.parentUuid)\(ID_SEPARATOR)\(idPair.uuid)\(ID_SEPARATOR)\(type)"
    let link = "http://www.cloudcards.h1n.ru/#\(linkBody)"
    return URL(string: link) ?? nil
}

/*
    Нижняя шторка - контроллер Поделиться
 */

public func showShareController(with url: URL, in controller: UIViewController) {
    let shareController = ShareController()
    shareController.modalPresentationStyle = .custom
    shareController.transitioningDelegate = controller as? UIViewControllerTransitioningDelegate
    shareController.url = url
    controller.present(shareController, animated: true, completion: nil)
}
