//
//  ProfileController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 17.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import RealmSwift

class ProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var data = [DataItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        let user = User()
        user.id = 0
        user.isOwner = 1
        user.name = "Владимир"
        user.surname = "Макаров"
        user.mobile = "+79121083757"
        user.email = "matteocarrera@mail.ru"
        
        try! realm.write {
            //realm.add(user)
        }
        
        let owner = realm.objects(User.self).filter("isOwner = 1")
        data = DataUtils.setDataToList(user: owner[0])
        
    }
    
    func configureTableView() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.register(DataTableViewCell.self, forCellReuseIdentifier: "DataCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
