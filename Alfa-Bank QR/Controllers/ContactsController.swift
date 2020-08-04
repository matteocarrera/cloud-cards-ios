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
    var selectedContactsUuid = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableUtils.configureTableView(table: contactsTable, controller: self)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPressGestureRecognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        contacts.removeAll()
        selectedContactsUuid.removeAll()
        
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
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let index = self.contactsTable.indexPathForRow(at: touchPoint)  {
                let contact = contacts[index.row]
                showContactMenu(contact: contact)
            }
        }
    }
    
    private func showContactMenu(contact : UserBoolean) {
        let alert = UIAlertController.init(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)
        
        let realm = try! Realm()
        
        alert.addAction(UIAlertAction.init(title: "QR код", style: .default, handler: { (_) in
            
            let qrController = self.storyboard?.instantiateViewController(withIdentifier: "QRController") as! QRController
            
            let contact = realm.objects(UserBoolean.self).filter("uuid = \"\(contact.uuid)\"")[0]
            let userLink = contact.parentId + "|" + contact.uuid

            qrController.userLink = userLink
            
            self.navigationController?.pushViewController(qrController, animated: true)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Поделиться", style: .default, handler: { (_) in
            
            let contact = realm.objects(UserBoolean.self).filter("uuid = \"\(contact.uuid)\"")[0]
            let userLink = contact.parentId + "|" + contact.uuid

            if let image = ProgramUtils.generateQR(userLink: userLink) {
                let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
                self.present(vc, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction.init(title: "Удалить", style: .default, handler: { (_) in
            try! realm.write {
                realm.delete(contact)
            }
            
            self.viewWillAppear(true)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
            
        self.present(alert, animated: true)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = contacts[indexPath.row]
        
        let parentViewController = self.parent as! CardsController
        if parentViewController.selectionIsActivated {
            if selectedContactsUuid.contains(dataCell.uuid) {
                selectedContactsUuid.remove(at: selectedContactsUuid.firstIndex(of: dataCell.uuid)!)
            } else {
                selectedContactsUuid.append(dataCell.uuid)
            }
            print(selectedContactsUuid)
        } else {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
            viewController.userId = dataCell.uuid
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

class ContactsCell : UITableViewCell {
    
    @IBOutlet var contactPhoto: UIImageView!
    @IBOutlet var contactName: UILabel!
    @IBOutlet var contactCompany: UILabel!
    @IBOutlet var contactJobTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TableUtils.setColorToSelectedRow(tableCell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
