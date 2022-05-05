import UIKit

/*
    Контроллер для представления экрана с QR и кнопкой поделиться
 */

class PresentationController: UIPresentationController {

  let blurEffectView: UIVisualEffectView!
  var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()

  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
      let blurEffect = UIBlurEffect(style: .dark)
      blurEffectView = UIVisualEffectView(effect: blurEffect)
      super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
      tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.blurEffectView.isUserInteractionEnabled = true
      self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
  }

  override var frameOfPresentedViewInContainerView: CGRect {
      CGRect(origin: CGPoint(x: 0, y: containerView!.frame.height * 0.4),
             size: CGSize(width: containerView!.frame.width, height: containerView!.frame.height *
              0.6))
  }

  override func presentationTransitionWillBegin() {
      blurEffectView.alpha = 0
      containerView?.addSubview(blurEffectView)
      presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
          self.blurEffectView.alpha = 0.7
      }, completion: { (_) in })
  }

  override func dismissalTransitionWillBegin() {
      presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
          self.blurEffectView.alpha = 0
      }, completion: { (_) in
          self.blurEffectView.removeFromSuperview()
      })
  }

  override func containerViewWillLayoutSubviews() {
      super.containerViewWillLayoutSubviews()
    presentedView!.roundCorners([.topLeft, .topRight], radius: 22)
  }

  override func containerViewDidLayoutSubviews() {
      super.containerViewDidLayoutSubviews()
      presentedView?.frame = frameOfPresentedViewInContainerView
      blurEffectView.frame = containerView!.bounds
  }

  @objc func dismissController() {
      presentedViewController.dismiss(animated: true, completion: nil)
  }
}

extension UIView {
  func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
      let path = UIBezierPath(
        roundedRect: bounds, byRoundingCorners: corners,
        cornerRadii: CGSize(width: radius, height: radius)
      )
      let mask = CAShapeLayer()
      mask.path = path.cgPath
      layer.mask = mask
  }
}
