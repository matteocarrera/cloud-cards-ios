import UIKit

class CompanyCell: UITableViewCell {

    public static let reuseIdentifier = "CompanyCell"

    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var companyAddressLabel: UILabel!
    @IBOutlet var companyEmailLabel: UILabel!

    public func update(with company: Company) {
        companyNameLabel.text = company.name
        companyAddressLabel.text = company.address.isEmpty ? "Адрес компании не указан" : company.address
        companyEmailLabel.text = company.email.isEmpty ? "Электронная почта компании не указана" : company.email
    }
}
