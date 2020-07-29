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
    var data = [DataItem]()
    var selectedItems = [DataItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        let rightBarItem : UIBarButtonItem
        let leftBarItem : UIBarButtonItem

        if #available(iOS 13.0, *) {
            rightBarItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(generateQR))
            leftBarItem = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(saveCardToTemplates))
        } else {
            rightBarItem = UIBarButtonItem(title: "QR", style: .plain, target: self, action: #selector(generateQR))
            leftBarItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveCardToTemplates))
        }
        
        self.navigationItem.rightBarButtonItem = rightBarItem
        self.navigationItem.leftBarButtonItem = leftBarItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedItems.removeAll()
        
        let realm = try! Realm()
        
        let owner = realm.objects(User.self)
        if owner.count != 0 {
            data = DataUtils.setDataToList(user: owner[0])
        } else {
            data = [DataItem]()
        }
        
        tableView.reloadData()
    }
    
    @objc fileprivate func generateQR() {
        if selectedItems.count != 0 {
            performSegue(withIdentifier: "QRView", sender: self)
        }
    }
    
    @objc fileprivate func saveCardToTemplates() {
        if selectedItems.count != 0 {
            saveUser(segue: nil)
            tabBarController?.selectedIndex = 0
            //performSegue(withIdentifier: "CardsView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveUser(segue: segue)
    }
    
    private func saveUser(segue : UIStoryboardSegue?) {
        var qrController : QRController? = nil
        if (segue?.identifier == "QRView") {
            qrController = segue?.destination as? QRController
        }
        let newUser = DataUtils.parseDataToUser(data: selectedItems)
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
        if (segue?.identifier == "QRView") {
            qrController?.userLink = newUser.parentId + "|" + newUser.uuid
        } else {
            let card = Card()
            card.color = "#FF0000"
            card.title = "TEST"
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
    
    private func configureTableView() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
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
