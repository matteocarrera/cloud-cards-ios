import UIKit
import MessageUI

private let reuseIdentifier = "DataCell"

class CardViewController: UIViewController {

    @IBOutlet weak var cardDataTable: UITableView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var cardPhoto: UIImageView!
    @IBOutlet var userInitialsLabel: UILabel!
    
    public var currentUser: User?
    public var currentCompany: Company?

    private let firebaseClient = FirebaseClientInstance.getInstance()
    private var data = [DataItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(closeWindow(_:)))
        backButton.tintColor = UIColor(named: "Primary")
        navigationItem.leftBarButtonItem = backButton
        
        configureTableView(table: cardDataTable, controller: self)
        cardPhoto.layer.cornerRadius = cardPhoto.frame.height/2
        if currentUser != nil {
            setExportButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = currentUser != nil ? "Визитка" : "Визитка компании"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserData()
        loadCompanyData()
        loadingIndicator.stopAnimating()
    }
    
    @objc func closeWindow(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func exportContact(_ sender: Any) {
        let alert = UIAlertController(
            title: "Экспорт контакта",
            message: "Вы действительно хотите экспортировать контакт?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.init(title: "Да", style: .default, handler: { (_) in
            exportToContacts(user: parseDataToUser(from: self.data), photo: self.cardPhoto.image, controller: self)
        }))
        alert.addAction(UIAlertAction.init(title: "Нет", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    /*
        Метод, устанавливающий данные компании в таблицу. Необходимо переопределить Constraints
     */
    
    private func loadCompanyData() {
        guard let currentCompany = currentCompany else {
            return
        }
        data = setCompanyDataToList(from: currentCompany)
        cardPhoto.isHidden = false
        let constraints = [
            cardDataTable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardDataTable.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardDataTable.widthAnchor.constraint(equalTo: view.widthAnchor),
            cardDataTable.heightAnchor.constraint(equalTo: view.heightAnchor,
                                                  constant: -navigationController!.navigationBar.frame.size.height)
        ]
        NSLayoutConstraint.activate(constraints)
        cardDataTable.reloadData()
    }
    
    /*
        Метод, устанавливащий данные компании в таблицу
     */
    
    private func loadUserData() {
        guard let currentUser = currentUser else {
            return
        }
        data = setDataToList(from: currentUser)
        userInitialsLabel.text = String(currentUser.name.character(at: 0)!) + String(currentUser.surname.character(at: 0)!)
        userInitialsLabel.isHidden = false
        if currentUser.photo != "" {
            firebaseClient.getPhoto(with: currentUser.photo) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(var image):
                        self.userInitialsLabel.isHidden = true
                        image = image.resizeWithPercent(percentage: 0.5)!
                        self.cardPhoto.image = image
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        
        cardDataTable.reloadData()
        cardPhoto.isHidden = false
    }
    
    private func setExportButton() {
        let exportButton = UIBarButtonItem(
            image: UIImage.init(systemName: "square.and.arrow.up"),
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(exportContact(_:))
        )
        exportButton.tintColor = UIColor(named: "Primary")
        
        navigationItem.rightBarButtonItem = exportButton
    }
}

extension CardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cardDataTable.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! DataCell

        return cell.update(with: data[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = data[indexPath.row]
        
        performActionWithField(title: dataCell.title, description: dataCell.data, controller: self)
        
        cardDataTable.reloadData()
    }
}

extension CardViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return currentCompany == nil ? CGFloat.leastNonzeroMagnitude : CGFloat(20)
    }
}

extension CardViewController: MFMailComposeViewControllerDelegate {}
