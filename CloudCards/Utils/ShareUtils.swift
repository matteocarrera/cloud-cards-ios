import UIKit

/*
    Вызов контроллера Поделиться, содержащего в себе ссылку на визитку пользователя на сайте
 */

public func showShareLinkController(with url: URL, in controller: UIViewController) {
    let shareInfo = "Вам отправили визитку! Просмотрите её по ссылке:"
    
    let vc = UIActivityViewController(activityItems: [shareInfo, url], applicationActivities: [])
    controller.present(vc, animated: true)
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
