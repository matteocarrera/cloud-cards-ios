import UIKit
import FirebaseStorage

class EditProfileController: UITableViewController {

    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var surnameField: UITextField!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var patronymicField: UITextField!
    @IBOutlet var companyField: UITextField!
    @IBOutlet var jobTitleField: UITextField!
    @IBOutlet var mobileNumberField: UITextField!
    @IBOutlet var mobileNumberSecondField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var emailSecondField: UITextField!
    @IBOutlet var addressField: UITextField!
    @IBOutlet var addressSecondField: UITextField!
    @IBOutlet var websiteField: UITextField!
    @IBOutlet var vkField: UITextField!
    @IBOutlet var telegramField: UITextField!
    @IBOutlet var facebookField: UITextField!
    @IBOutlet var instagramField: UITextField!
    @IBOutlet var twitterField: UITextField!

    private let realm = RealmInstance.getInstance()

    private var imagePickerController: UIImagePickerController?
    private var settingsController: SettingsController?
    // Пользователь, является основным для приложения
    private var mainUser: User?
    // Флаг, позволяющий отследить, изменялась ли фотография пользователя в процессе редактирования профиля или нет
    private var photoWasChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let settingsController = parent?.children.first as? SettingsController {
            self.settingsController = settingsController
        }

        /*
            TapGestureRecognizer позволяет добавить функционал нажатия на фотографию пользователя
         */

        let imageMenuTap = UITapGestureRecognizer(
            target: self,
            action: #selector(onImageTap(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(imageMenuTap)
        profileImage.layer.cornerRadius = profileImage.frame.height / 2

        /*
            TapGestureRecognizer для скрытия клавиатуры
         */

        let dismissTap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)

        setupToolbarForNumberKeyboard()
        loadUserData()
    }

    @IBAction func onCancelButtonTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onSaveButtonTap(_ sender: Any) {
        saveUserData()
    }

    /*
        Создание меню, появляющегося при нажатии на добавление фотографии
     */

    @objc func onImageTap(tapGestureRecognizer: UITapGestureRecognizer) {
        if imagePickerController != nil {
            imagePickerController?.delegate = nil
            imagePickerController = nil
        }

        self.imagePickerController = UIImagePickerController.init()

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
            self.profileImage.image = UIImage(systemName: "person.crop.circle.fill")
            self.profileImage.tintColor = UIColor(named: "Primary")
            self.photoWasChanged = true
        }))

        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }

    private func saveUserData() {
        if nameField.text!.isEmpty ||
            surnameField.text!.isEmpty ||
            mobileNumberField.text!.isEmpty ||
            emailField.text!.isEmpty {
            showSimpleAlert(
                withTitle: "Поля не заполнены",
                withMessage: "Обязательные поля: имя, фамилия, мобильный номер и электронная почта - не заполнены!",
                inController: self
            )
            return
        }

        var photoUuid = mainUser?.photo != nil ? mainUser?.photo : String()

        if photoWasChanged {

            /*
                Удаление старой фотографии пользователя из Firebase Storage
            */

            var storageRef = Storage.storage().reference().child(photoUuid!)
            storageRef.delete { error in
                if let error = error {
                    print("Ошибка во время удаления фотографии пользователя")
                    print(error)
                }
            }

            /*
                Добавление новой фотографии пользователя в Firebase Storage
             */

            if profileImage.image != nil && profileImage.image != UIImage(systemName: "person.crop.circle.fill") {
                guard let photo: UIImage = profileImage.image else { return }
                guard let photoData: Data = photo.jpegData(compressionQuality: 0.5) else { return }

                let md = StorageMetadata()
                md.contentType = "image/png"

                photoUuid = UUID().uuidString.lowercased()
                storageRef = Storage.storage().reference().child(photoUuid!)

                storageRef.putData(photoData, metadata: md) { (_, error) in
                    if let error = error {
                        print("Ошибка добавления фотографии в хранилище")
                        print(error)
                    }
                    self.settingsController?.getProfileInfo()
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                photoUuid = String()
            }
        }

        /*
            Сохранение пользователя в БД Realm
         */

        if mainUser == nil {

            let uuid = UUID().uuidString.lowercased()
            mainUser = User()
            updateUserData(ownerUser: mainUser!)
            mainUser?.parentId = uuid
            mainUser?.uuid = uuid
            mainUser?.photo = photoUuid!

            try? realm.write {
                realm.add(mainUser!)
            }
        } else {
            try? realm.write {
                updateUserData(ownerUser: mainUser!)
                mainUser?.photo = photoUuid!
                realm.add(mainUser!, update: .all)
            }
        }

        /*
            Сохранение пользователя в Firebase
         */

        let userData = JsonUtils.convertToDictionary(object: mainUser!)

        FirestoreInstance.getInstance()
            .collection(FirestoreInstance.USERS)
            .document(mainUser!.uuid)
            .collection(FirestoreInstance.DATA)
            .document(mainUser!.uuid)
            .setData(userData)

        settingsController?.getProfileInfo()
        navigationController?.popViewController(animated: true)
    }

    private func loadUserData() {

        /*
            Получение основного пользователя приложения
         */

        let userDictionary = realm.objects(User.self)

        if userDictionary.isEmpty {
            return
        }

        mainUser = userDictionary[0]
        setUserDataToFields(user: mainUser!)

        loadingIndicator.startAnimating()

        FirebaseClientInstance.getInstance().getPhoto(setImageTo: profileImage, with: mainUser!.photo) { result in
            switch result {
            case .success:
                self.loadingIndicator.stopAnimating()
            case .failure(let error):
                self.loadingIndicator.stopAnimating()
                print(error)
            }
        }
    }

    private func setUserDataToFields(user: User) {
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
        websiteField.text = user.website
        vkField.text = user.vk
        telegramField.text = user.telegram
        facebookField.text = user.facebook
        instagramField.text = user.instagram
        twitterField.text = user.twitter
    }

    private func updateUserData(ownerUser: User) {
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
        ownerUser.website = websiteField.text!
        ownerUser.vk = vkField.text!
        ownerUser.telegram = telegramField.text!
        ownerUser.facebook = facebookField.text!
        ownerUser.instagram = instagramField.text!
        ownerUser.twitter = twitterField.text!
    }

    private func presentImagePicker(controller: UIImagePickerController, source: UIImagePickerController.SourceType) {
        controller.delegate = self
        controller.sourceType = source
        present(controller, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 17 : 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(20)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

/*
    Расширение класса для использования камеры
 */

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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

/*
    Расширение класса для переключения между UITextField
 */

extension EditProfileController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = view.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
   }

    func setupToolbarForNumberKeyboard() {
        let bar = UIToolbar()
        let doneBtn = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()

        mobileNumberField.inputAccessoryView = bar
        mobileNumberSecondField.inputAccessoryView = bar
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
