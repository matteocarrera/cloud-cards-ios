import UIKit

class AboutAppController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
            showDevelopersAlert()
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
    
    private func showDevelopersAlert() {
        let alert = UIAlertController(title: "Владимир Макаров\nАнна Кислых", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
          alert.dismiss(animated: true, completion: nil)
        }
    }
}
