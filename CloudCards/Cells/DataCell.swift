import UIKit

class DataCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dataLabel: UILabel!
    
    public func update(with data: DataItem) -> DataCell {
        titleLabel.text = data.title
        dataLabel.text = data.data
        return self
    }
}
