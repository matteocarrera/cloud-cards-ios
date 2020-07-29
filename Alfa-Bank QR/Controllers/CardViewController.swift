//
//  CardViewController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 28.07.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseDatabase

class CardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cardDataTable: UITableView!
    @IBOutlet var cardPhoto: UIImageView!
    var data = [DataItem]()
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let realm = try! Realm()
        let owner = realm.objects(User.self)[0]
        
        let ref = Database.database().reference().child(owner.uuid).child(userId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let json = snapshot.value as? String {

                let jsonData = json.data(using: .utf8)!
                let userBoolean: UserBoolean = try! JSONDecoder().decode(UserBoolean.self, from: jsonData)
                  
                let currentUser = DataUtils.getUserFromTemplate(user: owner, userBoolean: userBoolean)
                
                self.data = DataUtils.setDataToList(user: currentUser)
                
                let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/alfa-bank-qr.appspot.com/o/\(owner.photo)?alt=media")
                let data = try? Data(contentsOf: url!)

                if let imageData = data {
                    let image = UIImage(data: imageData)
                    self.cardPhoto.image = image
                }
                  
                self.cardDataTable.reloadData()
             }
        })
        
        cardDataTable.reloadData()
    }
    
    func configureTableView() {
        self.view.addSubview(cardDataTable)
        cardDataTable.delegate = self
        cardDataTable.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cardDataTable.dequeueReusableCell(withIdentifier: "CardDataCell", for: indexPath) as! CardDataCell
        
        let dataCell = data[indexPath.row]
        cell.itemTitle.text = dataCell.title
        cell.itemDescription.text = dataCell.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

class CardDataCell : UITableViewCell {
    
    @IBOutlet var itemTitle: UILabel!
    @IBOutlet var itemDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
