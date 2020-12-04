import UIKit

private let reuseIdentifier = "DataCell"
private let reuseIdentifierCardParameters = "CardParametersCell"

class MyCardViewController: UITableViewController {
    
    @IBOutlet var cardDataTable: UITableView!
    
    public var currentCard = Card()
    public var currentUser = User()
    
    private let realm = RealmInstance.getInstance()
    private var data = [DataItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(closeWindow(_:))
        )
        backButton.tintColor = PRIMARY
        navigationItem.rightBarButtonItem = backButton
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifierCardParameters)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        data.removeAll()
        data = setDataToList(from: currentUser)
    }
    
    @objc func closeWindow(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1 : data.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 0) ? CGFloat(75) : CGFloat(55)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierCardParameters, for: indexPath)
            cell.textLabel?.text = currentCard.title
            cell.textLabel?.font = UIFont.systemFont(ofSize: 21.0, weight: .regular)
            cell.imageView?.image = UIImage.init(systemName: "square.fill")!
                .resized(toWidth: CGFloat(45))?
                .withTintColor(UIColor.init(hexString: currentCard.color))
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! DataCell

        let dataCell = data[indexPath.row]
        cell.titleLabel.text = dataCell.title
        cell.dataLabel.text = dataCell.data
        cell.selectionStyle = .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            showCardMenu()
        }
    }
    
    private func showCardMenu() {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let rename = UIAlertAction.init(title: "Переименовать", style: .default, handler: { (_) in
            
        })
        alert.addAction(rename)
        
        let changeColor = UIAlertAction.init(title: "Изменить цвет", style: .default, handler: { (_) in
            
        })
        alert.addAction(changeColor)
        
        let delete = UIAlertAction.init(title: "Удалить визитку", style: .destructive, handler: { (_) in
            
        })
        alert.addAction(delete)
        
        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
            
        self.present(alert, animated: true)
    }
}
