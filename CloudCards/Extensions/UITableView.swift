import UIKit

extension UITableView {

    public func deselectSelectedRows(animated: Bool)
    {
        self.indexPathsForSelectedRows?.forEach({ (indexPath) in
            self.deselectRow(at: indexPath, animated: animated)
        })
    }

}
