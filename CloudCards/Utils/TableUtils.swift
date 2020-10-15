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
    bgColorView.backgroundColor = PRIMARY_10
    tableCell.selectedBackgroundView = bgColorView
}
