import UIKit

/*
    Вызов контроллера Поделиться, содержащего в себе ссылку на визитку пользователя на сайте
 */

public func showShareLinkController(with idPair: String, in controller: UIViewController) {
    let shareInfo = "Вам отправили визитку! Просмотрите её по ссылке:"
    guard let siteLink = generateSiteLink(with: idPair) else { return }
    
    let vc = UIActivityViewController(activityItems: [shareInfo, siteLink], applicationActivities: [])
    controller.present(vc, animated: true)
}

/*
    Нижняя шторка - контроллер Поделиться
 */

public func showShareController(with idPair: String, in controller: UIViewController) {
    let shareController = ShareController()
    shareController.modalPresentationStyle = .custom
    shareController.transitioningDelegate = controller as? UIViewControllerTransitioningDelegate
    shareController.idPair = idPair
    controller.present(shareController, animated: true, completion: nil)
}
