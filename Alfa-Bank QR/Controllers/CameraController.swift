//
//  SecondViewController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 16.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift
import FirebaseDatabase

class SecondViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
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
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .lightContent
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Сканирование не поддерживается", message: "Ваше устройство не поддерживает функцию сканирования.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        let parentId = code.split(separator: "|")[0]
        let uuid = code.split(separator: "|")[1]
        
        let ref = Database.database().reference().child(String(parentId)).child(String(uuid))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
             if let json = snapshot.value as? String {

                let jsonData = json.data(using: .utf8)!
                let userBoolean: UserBoolean = try! JSONDecoder().decode(UserBoolean.self, from: jsonData)
                
                print(json)
                
                let realm = try! Realm()
                
                let existingUserDict = realm.objects(UserBoolean.self).filter("uuid = \"\(userBoolean.uuid)\"")
                
                if existingUserDict.count == 0 {
                    try! realm.write {
                        realm.add(userBoolean)
                        print("User successfully added!")
                    }
                    
                    realm.refresh()
                    
                    let alert = UIAlertController(title: "Успешно", message: "Контакт успешно отсканирован!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "ОК", style: .cancel, handler: { (_) in
                        self.tabBarController?.selectedIndex = 1
                        self.tabBarController?.selectedIndex = 0
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    let alert = UIAlertController(title: "Ошибка", message: "Такой пользователь уже существует!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "ОК", style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                    
                }
             }
        })
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}

