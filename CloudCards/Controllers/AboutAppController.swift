import UIKit

class AboutAppController: UITableViewController {

    @IBOutlet var appVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        appVersionLabel.text = appVersion
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 4 : 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectSelectedRows(animated: true)
        if indexPath.section == 0 && indexPath.row == 2 {
            showTimeAlert(
                withTitle: "Владимир Макаров\nАнна Кислых",
                withMessage: String(),
                showForSeconds: 2,
                inController: self
            )
            return
        }
        if indexPath.section == 1 {
            if let url = URL(string: "mailto:mks.development.group@gmail.com") {
                UIApplication.shared.open(url as URL, options: .init(), completionHandler: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return UITableView.automaticDimension
    }
}
