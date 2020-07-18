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

        if #available(iOS 13.0, *) {
            rightBarItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(generateQR))
        } else {
            rightBarItem = UIBarButtonItem(title: "QR", style: .plain, target: self, action: #selector(generateQR))
        }
        
        self.navigationItem.rightBarButtonItem = rightBarItem
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
            performSegue(withIdentifier: "segue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let qrController = segue.destination as! QRController
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
        qrController.userLink = newUser.parentId + "|" + newUser.uuid
    }
    
    func configureTableView() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
