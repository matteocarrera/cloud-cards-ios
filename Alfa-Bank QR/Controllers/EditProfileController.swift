//
//  EditProfileController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 04.06.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import RealmSwift

class EditProfileController: UIViewController {

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var patronymicField: UITextField!
    @IBOutlet weak var companyField: UITextField!
    @IBOutlet weak var jobTitleField: UITextField!
    @IBOutlet weak var mobileField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    private var ownerUser : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @IBAction func saveUser(_ sender: Any) {
        if ownerUser == nil {
            ownerUser = User()
            
            let realm = try! Realm()

            let maxValue = realm.objects(User.self).max(ofProperty: "id") as Int?
            
            try! realm.write {
                if (maxValue != nil) {
                    ownerUser?.id = maxValue! + 1
                } else {
                    ownerUser?.id = 0
                }
                ownerUser?.isOwner = 1
                updateUserData(ownerUser: ownerUser!)
                realm.add(ownerUser!)
            }
        } else {
            let realm = try! Realm()
            
            try! realm.write {
                var user = User()
                user = ownerUser!
                updateUserData(ownerUser: user)
                realm.add(ownerUser!, update: .all)
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setUserDataToFields(user : User) {
        surnameField.text = user.surname
        nameField.text = user.name
        patronymicField.text = user.patronymic
        companyField.text = user.company
        jobTitleField.text = user.jobTitle
        mobileField.text = user.mobile
        emailField.text = user.email
    }
    
    private func updateUserData(ownerUser : User) {
        ownerUser.name = nameField.text as! String
        ownerUser.surname = surnameField.text as! String
        ownerUser.patronymic = patronymicField.text as! String
        ownerUser.company = companyField.text as! String
        ownerUser.jobTitle = jobTitleField.text as! String
        ownerUser.mobile = mobileField.text as! String
        ownerUser.email = emailField.text as! String
    }
}
