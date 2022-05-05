import UIKit

/*
    Простой Alert, содержащий в себе заголовок и текст
 */

public func showSimpleAlert(
    withTitle title: String,
    withMessage message: String,
    inController controller: UIViewController
) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default))
    controller.present(alertController, animated: true)
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
    DispatchQueue.main.asyncAfter(deadline: when) {
      alert.dismiss(animated: true, completion: nil)
    }
}
