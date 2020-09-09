//
//  SelectDataController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 06.06.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseDatabase

class SelectDataController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var createProfileNotification: UILabel!
    var data = [DataItem]()
    var selectedItems = [DataItem]()
    var colors = ["#FF0000", "#00FF00", "#0000FF", "#7B4987", "#48a89a", "#c5db37", "#cf9211", "#7c888a", "#000000"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        TableUtils.configureTableView(table: tableView, controller: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedItems.removeAll()
        
        let realm = try! Realm()
        
        let owner = realm.objects(User.self)
        if owner.count != 0 {
            data = DataUtils.setDataToList(user: owner[0])
            createProfileNotification.isHidden = true
        } else {
            data = [DataItem]()
            createProfileNotification.isHidden = false
        }
        
        tableView.reloadData()
    }
    
    @IBAction func generateQR(_ sender: Any) {
        if selectedItems.count != 0 {
            saveUser(segue: "QRView", title: nil)
        } else {
            showAlert()
        }
    }

    @IBAction func saveCardToTemplates(_ sender: Any) {
        if selectedItems.count != 0 {
            showSaveAlert()
        } else {
            showAlert()
        }
    }
    
    private func showSaveAlert() {
        let alert = UIAlertController(title: "Сохранение визитки", message: "Введите имя визитки", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.saveUser(segue: "", title: textField?.text)
            self.tabBarController?.selectedIndex = 0
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
    
    private func saveUser(segue : String, title : String?) {
        let newUser = DataUtils.parseDataToUserBoolean(data: selectedItems)
        let realm = try! Realm()
        let ownerUser = realm.objects(User.self)
        newUser.parentId = ownerUser[0].parentId
        let users = realm.objects(UserBoolean.self)
        var userExists = false
        for user in users {
            if DataUtils.generatedUsersEqual(firstUser: newUser, secondUser: user) {
                newUser.uuid = user.uuid
                userExists = true
            }
        }
        if !userExists {
            let uuid = UUID().uuidString
            newUser.uuid = uuid
            
            let ref = Database.database().reference()
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(newUser)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            
            ref.child(newUser.parentId).child(newUser.uuid).setValue(json)
            
            try! realm.write {
                realm.add(newUser)
            }
        }
        if (segue == "QRView") {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "QRController") as! QRController
            viewController.userLink = newUser.parentId + "|" + newUser.uuid
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            let card = Card()
            let randomInt = Int.random(in: 0..<colors.count)
            card.color = colors[randomInt]
            card.title = title!
            card.userId = newUser.uuid
            let maxValue = realm.objects(Card.self).max(ofProperty: "id") as Int?
            if (maxValue != nil) {
                card.id = maxValue! + 1
            } else {
                card.id = 0
            }
            try! realm.write {
                realm.add(card)
            }
        }
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as! TestCell
        
        let dataCell = data[indexPath.row]
        cell.descriptionText?.text = dataCell.description
        cell.titleText?.text = dataCell.title
        
        if dataCell.isSelected
        {
            if #available(iOS 13.0, *) {
                cell.buttonTick.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: UIControl.State.normal)
            } else {
                cell.accessoryType = .checkmark
            }
        }
        else
        {
            if #available(iOS 13.0, *) {
                cell.buttonTick.setBackgroundImage(UIImage(systemName: "circle"), for: UIControl.State.normal)
            } else {
                cell.accessoryType = .none
            }
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = data[indexPath.row]
        dataCell.isSelected = !dataCell.isSelected
        
        if !selectedItems.contains(where: { $0.title == dataCell.title }) {
            selectedItems.append(DataItem(title: dataCell.title, description: dataCell.description))
        } else {
            selectedItems.removeAll(where: { $0.title == dataCell.title })
        }
        
        tableView.reloadData()
    }

    private func showAlert() {
        ProgramUtils.showAlert(controller: self, title: "Данные не выбраны", message: "Вы не выбрали ни одного поля!")
    }
}

class TestCell : UITableViewCell {
    
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var buttonTick: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
