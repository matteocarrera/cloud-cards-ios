import UIKit
import RealmSwift
import FirebaseDatabase
import FirebaseStorage

class EditProfileController: UIViewController, UITextFieldDelegate {
    
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
    private let realm : Realm = try! Realm()
    
    // Контроллер, отвечающий за работу выбора фотографии пользователя для его профиля
    private var imagePickerController : UIImagePickerController?
    // Пользователь, являюемся основным для приложения
    private var ownerUser : User?
    // Флаг, позволяющий отследить, изменялась ли фотография пользователя в процессе редактирования профиля или нет
    private var photoWasChanged = false
    // Правая кнопка навигации
    private var rightBarButtonItem : UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
            TapGestureRecognizer позволяет добавить функионал нажатия на фотографию пользователя
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
        
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        photoWasChanged = false
        
        /*
            Получение основного пользователя приложения
         */
        
        let query = realm.objects(User.self)
        if query.count != 0 {
            ownerUser = query[0]
            setUserDataToFields(user: ownerUser!)
            
            profileImage.image = DataBaseUtils.getPhotoFromDatabase(photoUuid: ownerUser!.photo)
        }
    }
    
    /*
        TODO("Баг с пропадающими полями при редактировании профиля")
     */
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -260, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -260, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
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
                    print("Ошибка во время удаления фотографии пользователя")
                    print(error)
                  } else {
                    print("Фотография удачно удалена")
                  }
                }
            }
            
            /*
                Добавление новой фотографии пользователя в Firebase Storage
             */
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
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        /*
            Сохранение пользователя в БД Realm
         */
        
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
            Сохранение пользователя в Firebase
         */
        
        let json = convertToJson(someUser: ownerUser!)
        
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
