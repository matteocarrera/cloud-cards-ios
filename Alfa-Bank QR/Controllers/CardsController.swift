//
//  FirstViewController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 16.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import RealmSwift

class CardsController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    var data = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let realm = try! Realm()
    
        let owner = realm.objects(User.self).filter("isScanned = 1")
        if owner.count != 0 {
            let array = Array(owner)
            data = array
        } else {
            data = [User]()
        }
        
        tableView.reloadData()
    }
    
    /*override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }*/
    
    func configureTableView() {
        self.view.addSubview(tableView)
        tableView.rowHeight = 80
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! SavedCardsTableCell
        
        let dataCell = data[indexPath.row]
        cell.name?.text = dataCell.name + " " + dataCell.surname
        cell.jobTitle?.text = dataCell.jobTitle
        cell.company?.text = dataCell.company
        
        return cell
    }
}

class SavedCardsTableCell : UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var company: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
