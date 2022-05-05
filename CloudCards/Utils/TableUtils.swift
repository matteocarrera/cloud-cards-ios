import UIKit

public func configureTableView(table: UITableView, controller: UIViewController) {
    controller.view.addSubview(table)
    table.delegate = (controller as? UITableViewDelegate)
    table.dataSource = (controller as? UITableViewDataSource)
    table.tableFooterView = UIView()
}
