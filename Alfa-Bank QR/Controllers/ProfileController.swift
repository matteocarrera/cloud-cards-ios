//
//  ProfileController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 17.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseStorage

class ProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var createProfileNotification: UILabel!
    var data = [DataItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        userPhoto.layer.cornerRadius = userPhoto.frame.height/2
        TableUtils.configureTableView(table: tableView, controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let realm = try! Realm()
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        let owner = realm.objects(User.self)
        if owner.count != 0 {
            createProfileNotification.isHidden = true
            userPhoto.isHidden = false
            data = DataUtils.setDataToList(user: owner[0])
            
            let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/alfa-bank-qr.appspot.com/o/\(owner[0].photo)?alt=media")
            let data = try? Data(contentsOf: url!)

            if let imageData = data {
                let image = UIImage(data: imageData)
                userPhoto.image = image
            }
            
        } else {
            createProfileNotification.isHidden = false
            userPhoto.isHidden = true
            data = [DataItem]()
        }
    
        tableView.reloadData()
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! DataTableViewCell
        
        let dataCell = data[indexPath.row]
        cell.descriptionText?.text = dataCell.description
        cell.titleText?.text = dataCell.title
        
        return cell
    }
    
    
}

class DataTableViewCell : UITableViewCell {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
