import Foundation
import UIKit

public func configureTableView(table: UITableView, controller: UIViewController) {
    controller.view.addSubview(table)
    table.delegate = (controller as! UITableViewDelegate)
    table.dataSource = (controller as! UITableViewDataSource)
    table.tableFooterView = UIView()
}

public func setColorToSelectedRow(tableCell: UITableViewCell) {
    let bgColorView = UIView()
    bgColorView.backgroundColor = PRIMARY_10
    tableCell.selectedBackgroundView = bgColorView
}

public func setTopSeparator(table: UITableView) {
    let line = UIView(frame: CGRect(x: 0, y: 0, width: table.frame.size.width, height: 1 / UIScreen.main.scale))
    line.backgroundColor = table.separatorColor
    
    table.tableHeaderView = line
}

public func setBottomSeparator(table: UITableView) {
    let line = UIView(frame: CGRect(x: 0, y: 0, width: table.frame.size.width, height: 1 / UIScreen.main.scale))
    line.backgroundColor = table.separatorColor
    
    table.tableFooterView = line
}
