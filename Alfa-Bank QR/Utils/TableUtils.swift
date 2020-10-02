//
//  TableUtils.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 31.07.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation
import UIKit

public func configureTableView(table : UITableView, controller : UIViewController) {
    controller.view.addSubview(table)
    table.delegate = (controller as! UITableViewDelegate)
    table.dataSource = (controller as! UITableViewDataSource)
    table.tableFooterView = UIView()
}

public func setColorToSelectedRow(tableCell : UITableViewCell) {
    let bgColorView = UIView()
    bgColorView.backgroundColor = UIColor(hexString: selectedRowColor)
    tableCell.selectedBackgroundView = bgColorView
}
