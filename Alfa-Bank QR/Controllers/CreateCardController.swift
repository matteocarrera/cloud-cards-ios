//
//  CreateCardController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 31.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import RealmSwift

class CreateCardController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var data = [DataItem]()
    var selectedItems = [DataItem]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        let realm = try! Realm()
        
        let owner = realm.objects(User.self).filter("isOwner = 1")
        data = DataUtils.setDataToList(user: owner[0])
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! SelectedDataTableViewCell
        
        let dataCell = data[indexPath.row]
        cell.descriptionText?.text = dataCell.description
        cell.titleText?.text = dataCell.title
        
        if dataCell.isSelected
        {
            cell.accessoryType = .checkmark
            cell.backgroundColor = UIColor(red: 11/255, green: 31/255, blue: 53/255, alpha: 0.04)
        }
        else
        {
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.clear
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
        print(selectedItems.count)
        
        tableView.reloadData()
    }
}

class SelectedDataTableViewCell : UITableViewCell {
    
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var titleText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
