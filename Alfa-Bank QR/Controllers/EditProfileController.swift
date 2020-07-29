//
//  EditProfileController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 04.06.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseDatabase
import FirebaseStorage

class EditProfileController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var patronymicField: UITextField!
    @IBOutlet weak var companyField: UITextField!
    @IBOutlet weak var jobTitleField: UITextField!
    @IBOutlet weak var mobileNumberField: UITextField!
    @IBOutlet weak var mobileNumberSecondField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailSecondField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var addressSecondField: UITextField!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var cardNumberSecondField: UITextField!
    @IBOutlet weak var websiteField: UITextField!
    @IBOutlet weak var vkField: UITextField!
    @IBOutlet weak var telegramField: UITextField!
    @IBOutlet weak var facebookField: UITextField!
    @IBOutlet weak var instagramField: UITextField!
    @IBOutlet weak var twitterField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    
    var imagePickerController : UIImagePickerController?
    var ownerUser : User?
    var photoWasChanged = false
    var rightBarButtonItem : UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        
        rightBarButtonItem = UIBarButtonItem(
            title: "Готово",
            style: .plain,
            target: self,
            action: #selector(saveUser)
        )
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        photoWasChanged = false
        
        let realm = try! Realm()
        
        let query = realm.objects(User.self)
        if query.count != 0 {
            ownerUser = query[0]
            setUserDataToFields(user: ownerUser!)
            
            let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/alfa-bank-qr.appspot.com/o/\(ownerUser!.photo)?alt=media")
            let data = try? Data(contentsOf: url!)

            if let imageData = data {
                let image = UIImage(data: imageData)
                profileImage.image = image
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /*
        Создание меню, появляющегося при нажатии на добавление фотографии
     */
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if self.imagePickerController != nil {
            self.imagePickerController?.delegate = nil
            self.imagePickerController = nil
        }
        
        self.imagePickerController = UIImagePickerController.init()
        
        let alert = UIAlertController.init(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction.init(title: "Сделать снимок", style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, source: .camera)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction.init(title: "Выбрать из библиотеки", style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, source: .photoLibrary)
            }))
        }
        
        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
            
        self.present(alert, animated: true)
    }

    @objc func saveUser() {
        rightBarButtonItem?.isEnabled = false
        var photoUuid = ownerUser?.photo
        
        if photoUuid == nil {
            photoUuid = ""
        }
        
        /*
            Удаление старой фотографии пользователя из Firebase Storage
        */
        if profileImage.image != nil && photoWasChanged {
            var storageRef = Storage.storage().reference()
            if photoUuid != "" {
                storageRef = Storage.storage().reference().child(photoUuid!)

                storageRef.delete { error in
                  if let error = error {
                    print("Error while deleting a file")
                    print(error)
                  } else {
                    print("File successfully deleted")
                  }
                }
            }
            
            /*
                Добавление новой фотографии пользователя в Firebase Storage
             */
            guard let im: UIImage = profileImage.image else { return }
            guard let d: Data = im.jpegData(compressionQuality: 0.5) else { return }

            let md = StorageMetadata()
            md.contentType = "image/png"

            photoUuid = UUID().uuidString
            storageRef = Storage.storage().reference().child(photoUuid!)

            storageRef.putData(d, metadata: md) { (metadata, error) in
                if error == nil {
                    storageRef.downloadURL(completion: { (url, error) in
                        print("Done, url is \(String(describing: url))")
                    })
                } else {
                    print("error \(String(describing: error))")
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        let realm = try! Realm()
        let ref = Database.database().reference()
        if ownerUser == nil {
            
            let uuid = UUID().uuidString
            ownerUser = User()
            updateUserData(ownerUser: ownerUser!)
            ownerUser?.parentId = uuid
            ownerUser?.uuid = uuid
            ownerUser?.photo = photoUuid!
            
            try! realm.write {
                realm.add(ownerUser!)
            }
        } else {
            try! realm.write {
                updateUserData(ownerUser: ownerUser!)
                ownerUser?.photo = photoUuid!
                realm.add(ownerUser!, update: .all)
            }
        }
        
        /*
            Перевод данных пользователя в JSON
         */
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(ownerUser)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        ref.child(ownerUser!.parentId).child(ownerUser!.uuid).setValue(json)
        
        if !photoWasChanged {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setUserDataToFields(user : User) {
        surnameField.text = user.surname
        nameField.text = user.name
        patronymicField.text = user.patronymic
        companyField.text = user.company
        jobTitleField.text = user.jobTitle
        mobileNumberField.text = user.mobile
        mobileNumberSecondField.text = user.mobileSecond
        emailField.text = user.email
        emailSecondField.text = user.emailSecond
        addressField.text = user.address
        addressSecondField.text = user.addressSecond
        cardNumberField.text = user.cardNumber
        cardNumberSecondField.text = user.cardNumberSecond
        websiteField.text = user.website
        vkField.text = user.vk
        telegramField.text = user.telegram
        facebookField.text = user.facebook
        instagramField.text = user.instagram
        twitterField.text = user.twitter
        notesField.text = user.notes
    }
    
    private func updateUserData(ownerUser : User) {
        ownerUser.name = nameField.text!
        ownerUser.surname = surnameField.text!
        ownerUser.patronymic = patronymicField.text!
        ownerUser.company = companyField.text!
        ownerUser.jobTitle = jobTitleField.text!
        ownerUser.mobile = mobileNumberField.text!
        ownerUser.mobileSecond = mobileNumberSecondField.text!
        ownerUser.email = emailField.text!
        ownerUser.emailSecond = emailSecondField.text!
        ownerUser.address = addressField.text!
        ownerUser.addressSecond = addressSecondField.text!
        ownerUser.cardNumber = cardNumberField.text!
        ownerUser.cardNumberSecond = cardNumberSecondField.text!
        ownerUser.website = websiteField.text!
        ownerUser.vk = vkField.text!
        ownerUser.telegram = telegramField.text!
        ownerUser.facebook = facebookField.text!
        ownerUser.instagram = instagramField.text!
        ownerUser.twitter = twitterField.text!
        ownerUser.notes = notesField.text!
    }
    
    internal func presentImagePicker(controller : UIImagePickerController, source : UIImagePickerController.SourceType) {
        controller.delegate = self
        controller.sourceType = source
        self.present(controller, animated: true)
    }
}

/*
    Расширение класса для использования библиотеки и камеры
 */
extension EditProfileController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return self.imagePickerControllerDidCancel(picker)
        }
        self.profileImage.image = image
        photoWasChanged = true
        picker.dismiss(animated: true) {
            picker.delegate = nil
            self.imagePickerController!.delegate = nil
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            picker.delegate = nil
            self.imagePickerController!.delegate = nil
        }
    }
}
