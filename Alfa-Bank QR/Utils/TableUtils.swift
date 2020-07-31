//
//  TableUtils.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 31.07.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation
import UIKit

class TableUtils {
    
    static func configureTableView(table : UITableView, controller : UIViewController) {
        controller.view.addSubview(table)
        table.delegate = (controller as! UITableViewDelegate)
        table.dataSource = (controller as! UITableViewDataSource)
        table.tableFooterView = UIView()
    }
    
    static func setColorToSelectedRow(tableCell : UITableViewCell) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(hexString: "#D8D8D8")
        tableCell.selectedBackgroundView = bgColorView
    }
}
