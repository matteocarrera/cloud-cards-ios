import UIKit

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
