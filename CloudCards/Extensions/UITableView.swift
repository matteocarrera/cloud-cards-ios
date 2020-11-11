import Foundation
import UIKit

extension UITableView {

    public func deselectSelectedRow(animated: Bool)
    {
        self.indexPathsForSelectedRows?.forEach({ (indexPath) in
            self.deselectRow(at: indexPath, animated: animated)
        })
    }

}
