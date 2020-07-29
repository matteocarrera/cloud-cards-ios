//
//  ContactsController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 29.07.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseDatabase
import FirebaseStorage

class ContactsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var contactsTable: UITableView!
    var contacts = [UserBoolean]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contacts.removeAll()
        
        let realm = try! Realm()

        let userDictionary = realm.objects(User.self)
        if userDictionary.count != 0 {
            let owner = userDictionary[0]
            contacts = Array(realm.objects(UserBoolean.self).filter("parentId != \"\(owner.uuid)\""))
        } else {
            contacts = Array(realm.objects(UserBoolean.self))
        }
        
        contactsTable.reloadData()
    }
    
    func configureTableView() {
        self.view.addSubview(contactsTable)
        contactsTable.delegate = self
        contactsTable.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTable.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! ContactsCell
        
        let dataCell = contacts[indexPath.row]

        let user = dataCell
        
        let ref = Database.database().reference().child(user.parentId).child(user.parentId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let json = snapshot.value as? String {

                let jsonData = json.data(using: .utf8)!
                let parentUser: User = try! JSONDecoder().decode(User.self, from: jsonData)
                  
                let currentUser = DataUtils.getUserFromTemplate(user: parentUser, userBoolean: user)

                let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/alfa-bank-qr.appspot.com/o/\(parentUser.photo)?alt=media")
                let data = try? Data(contentsOf: url!)

                if let imageData = data {
                    let image = UIImage(data: imageData)
                    cell.contactPhoto.image = image
                    cell.contactPhoto.layer.cornerRadius = cell.contactPhoto.frame.height/2
                }
                  
                cell.contactName.text = currentUser.name + " " + currentUser.surname
                
                if currentUser.company != "" {
                    cell.contactCompany.text = currentUser.company
                } else {
                    cell.contactCompany.text = "Компания не указана"
                }
                
                if currentUser.jobTitle != "" {
                    cell.contactJobTitle.text = currentUser.jobTitle
                } else {
                    cell.contactJobTitle.text = "Должность не указана"
                }
             }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

class ContactsCell : UITableViewCell {
    
    @IBOutlet var contactPhoto: UIImageView!
    @IBOutlet var contactName: UILabel!
    @IBOutlet var contactCompany: UILabel!
    @IBOutlet var contactJobTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
