import UIKit
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
    
    // Объект Realm, позволяющий осуществлять операции с локальной БД
    private let realm = RealmInstance.getInstance()
    
    // Контроллер, отвечающий за работу выбора фотографии пользователя для его профиля
    private var imagePickerController : UIImagePickerController?
    // Пользователь, являюемся основным для приложения
    private var ownerUser : User?
    // Флаг, позволяющий отследить, изменялась ли фотография пользователя в процессе редактирования профиля или нет
    private var photoWasChanged = false
    // Правая кнопка навигации
    private var rightBarButtonItem: UIBarButtonItem?
    private var settingsController: SettingsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsController = (self.parent?.children.first as! SettingsController)
        
        /*
            TapGestureRecognizer позволяет добавить функционал нажатия на фотографию пользователя
         */
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        
        rightBarButtonItem = UIBarButtonItem(
            title: "Готово",
            style: .plain,
            target: self,
            action: #selector(saveUser)
        )
        rightBarButtonItem?.tintColor = PRIMARY
        
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        photoWasChanged = false
        
        /*
            Получение основного пользователя приложения
         */
        
        let userDictionary = realm.objects(User.self)
        if userDictionary.count != 0 {
            ownerUser = userDictionary[0]
            setUserDataToFields(user: ownerUser!)
            
            profileImage.image = getPhotoFromDatabase(photoUuid: ownerUser!.photo)
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
        if imagePickerController != nil {
            imagePickerController?.delegate = nil
            imagePickerController = nil
        }
        
        imagePickerController = UIImagePickerController.init()
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
        
        alert.addAction(UIAlertAction.init(title: "Удалить фото", style: .destructive, handler: { (_) in
            self.profileImage.image = nil
            self.photoWasChanged = true
        }))
        
        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
            
        present(alert, animated: true)
    }

    @objc func saveUser() {
        if nameField.text!.isEmpty ||
            surnameField.text!.isEmpty ||
            mobileNumberField.text!.isEmpty ||
            emailField.text!.isEmpty {
            showSimpleAlert(
                withTitle: "Поля не заполнены",
                withMessage: "Обязательные поля: имя, фамилия, мобильный номер и email - не заполнены!",
                inController: self
            )
            return
        }
        
        rightBarButtonItem?.isEnabled = false
        var photoUuid = ownerUser?.photo
        
        if photoUuid == nil {
            photoUuid = ""
        }
        
        /*
            Удаление старой фотографии пользователя из Firebase Storage
        */
        if photoWasChanged {
            var storageRef : FirebaseStorage.StorageReference
            if photoUuid != "" {
                storageRef = Storage.storage().reference().child(photoUuid!)

                storageRef.delete { error in
                    if let error = error {
                        print("Ошибка во время удаления фотографии пользователя")
                        print(error)
                    } else {
                        print("Фотография успешно удалена")
                    }
                }
            }
            
            /*
                Добавление новой фотографии пользователя в Firebase Storage
             */
            if profileImage.image != nil {
                guard let photo: UIImage = profileImage.image else { return }
                guard let photoData: Data = photo.jpegData(compressionQuality: 0.5) else { return }

                let md = StorageMetadata()
                md.contentType = "image/png"

                photoUuid = UUID().uuidString
                storageRef = Storage.storage().reference().child(photoUuid!)

                storageRef.putData(photoData, metadata: md) { (metadata, error) in
                    if error == nil {
                        storageRef.downloadURL(completion: { (url, error) in
                            print("Done, url is \(String(describing: url))")
                        })
                    } else {
                        print("error \(String(describing: error))")
                    }
                    self.settingsController?.getProfileInfo()
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                photoUuid = ""
                settingsController?.getProfileInfo()
                navigationController?.popViewController(animated: true)
            }
        }
        
        /*
            Сохранение пользователя в БД Realm
         */
        
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
            Сохранение пользователя в Firebase
         */
        let userData = convertToDictionary(someUser: ownerUser!)

        let db = FirestoreInstance.getInstance()
        db.collection(FirestoreInstance.USERS)
            .document(ownerUser!.uuid)
            .collection(FirestoreInstance.DATA)
            .document(ownerUser!.uuid)
            .setData(userData)
        
        if !photoWasChanged {
            settingsController?.getProfileInfo()
            navigationController?.popViewController(animated: true)
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
    
    func presentImagePicker(controller : UIImagePickerController, source : UIImagePickerController.SourceType) {
        controller.delegate = self
        controller.sourceType = source
        present(controller, animated: true)
    }
}

/*
    Расширение класса для использования библиотеки и камеры
 */
extension EditProfileController: UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return imagePickerControllerDidCancel(picker)
        }
        profileImage.image = image
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

extension EditProfileController: UINavigationControllerDelegate {}
