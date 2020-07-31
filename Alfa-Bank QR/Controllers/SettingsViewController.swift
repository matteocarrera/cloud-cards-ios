//
//  SettingsViewController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 06.06.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet var settingsTable: UITableView!
    var items = [String]()
    var identities = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTable.tableFooterView = UIView()
        items = ["Конфиденциальность", "Пользовательское соглашение", "Помощь", "О приложении"]
        identities = ["Privacy", "TermsOfUse", "Help", "AboutApp"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        TableUtils.setColorToSelectedRow(tableCell: cell!)
        
        cell?.textLabel?.text = items[indexPath.row]
        cell?.textLabel?.textColor = UIColor.black
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewControllerName = identities[indexPath.row]
        let viewController = storyboard?.instantiateViewController(withIdentifier: viewControllerName)
        self.navigationController?.pushViewController(viewController!, animated: true)
    }}
