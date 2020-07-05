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
    
    var ownerUser : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightBarButtonItem = UIBarButtonItem(
            title: "Готово",
            style: .plain,
            target: self,
            action: #selector(saveUser)
        )
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let realm = try! Realm()
        
        let query = realm.objects(User.self).filter("isOwner = 1")
        if query.count != 0 {
            ownerUser = query[0]
            setUserDataToFields(user: ownerUser!)
        }
    }

    @objc func saveUser() {
        let realm = try! Realm()
        let ref = Database.database().reference()
        if ownerUser == nil {
            
            let uuid = UUID().uuidString
            ownerUser = User()
            updateUserData(ownerUser: ownerUser!)
            ownerUser?.id = uuid
            ownerUser?.isOwner = true
            ownerUser?.isScanned = false
            
            try! realm.write {
                realm.add(ownerUser!)
            }
        } else {
            try! realm.write {
                updateUserData(ownerUser: ownerUser!)
                realm.add(ownerUser!, update: .all)
            }
        }
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(ownerUser)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        ref.child(ownerUser!.id).setValue(json)
                
        self.navigationController?.popViewController(animated: true)
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
}
