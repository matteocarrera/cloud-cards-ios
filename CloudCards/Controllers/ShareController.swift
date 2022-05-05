import UIKit

class ShareController: UIViewController {

    @IBOutlet weak var slideIdicator: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIView!

    public var url = URL(string: String())

    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shareButtonClicked))
        shareButton.addGestureRecognizer(tapGestureRecognizer)

        slideIdicator.roundCorners(.allCorners, radius: 10)
        shareButton.roundCorners(.allCorners, radius: 10)
    }

    override func viewWillAppear(_ animated: Bool) {
        imageView.image = generateQR(with: url!)
    }

    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = view.frame.origin
        }
    }

    @objc func shareButtonClicked() {
        shareBusinessCard(with: url!, in: self)
    }

    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)

        // Запрещаем пользователю двигать окно вверх
        guard translation.y >= 0 else { return }

        // Задаем возможность пользователю двигать окно только вверх/вниз
        view.frame.origin = CGPoint(x: 0, y: pointOrigin!.y + translation.y)

        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                dismiss(animated: true, completion: nil)
            } else {
                // Задаем начальное значение контроллера
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}
