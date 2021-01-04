import UIKit
import AVFoundation

class CameraController: UIViewController {

    @IBOutlet var cameraView: UIView!
    @IBOutlet var qrAreaView: UIView!
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        qrAreaView.layer.cornerRadius = 15
        qrAreaView.layer.borderWidth = 2
        qrAreaView.layer.borderColor = UIColor.white.cgColor
        
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.stopRunning()
        }
    }

    private func failed() {
        showSimpleAlert(
            withTitle: "Сканирование не поддерживается",
            withMessage: "Ваше устройство не поддерживает функцию сканирования!",
            inController: self
        )
        captureSession = nil
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CameraController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            saveUserIfDataIsCorrect(data: stringValue)
        }
    }
    
    // Проверка данных, полученных с QR. Если есть "|", то сохраняем, иначе данные некорректны
    private func saveUserIfDataIsCorrect(data: String) {
        if data.contains(ID_SEPARATOR) {
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
            getUserFromQR(from: rootViewController, with: data)
            return
        }
        showUnableToReadQRAlert()
    }
    
    private func showUnableToReadQRAlert() {
        captureSession.stopRunning()
        
        let alert = UIAlertController(title: "Ошибка", message: "QR код невозможно считать!", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "ОК", style: .cancel, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
