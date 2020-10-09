import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet var settingsTable: UITableView!
    private var items = [String]()
    private var identities = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTable.tableFooterView = UIView()
        items = ["Конфиденциальность", "Пользовательское соглашение", "Помощь", "О приложении"]
        identities = ["Privacy", "TermsOfUse", "Help", "AboutApp"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        setColorToSelectedRow(tableCell: cell!)
        
        cell?.textLabel?.text = items[indexPath.row]
        cell?.textLabel?.textColor = UIColor.black
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewControllerName = identities[indexPath.row]
        let viewController = storyboard?.instantiateViewController(withIdentifier: viewControllerName)
        self.navigationController?.pushViewController(viewController!, animated: true)
    }}
