import UIKit

class CreateCardCompanyController: UITableViewController {

    @IBOutlet var cardNameField: UITextField!
    @IBOutlet var companyNameField: UITextField!
    @IBOutlet var responsibleNameField: UITextField!
    @IBOutlet var responsibleJobTitleField: UITextField!
    @IBOutlet var companyAddressField: UITextField!
    @IBOutlet var companyPhoneField: UITextField!
    @IBOutlet var companyEmailField: UITextField!
    @IBOutlet var companySiteField: UITextField!
    
    public var templateCard: Card? = nil
    
    private var cardColor = COLORS[Int.random(in: 0..<COLORS.count)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if templateCard != nil {
            let ownerUser = RealmInstance.getInstance().objects(User.self)[0]
            FirebaseClientInstance.getInstance().getUser(
                firstKey: ownerUser.uuid,
                secondKey: templateCard!.cardUuid,
                firstKeyPath: FirestoreInstance.USERS,
                secondKeyPath: FirestoreInstance.CARDS) { result in
                switch result {
                case .success(let data):
                    let businessCard = JsonUtils.convertFromDictionary(dictionary: data, type: BusinessCard<Company>.self)
                    let company = businessCard.data
                    self.cardNameField.text = self.templateCard?.title
                    self.companyNameField.text = company.name
                    self.responsibleNameField.text = company.responsibleFullName
                    self.responsibleJobTitleField.text = company.responsibleJobTitle
                    self.companyAddressField.text = company.address
                    self.companyPhoneField.text = company.phone
                    self.companyEmailField.text = company.email
                    self.companySiteField.text = company.website
                    let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0))
                    cell?.imageView?.tintColor = UIColor(hexString: self.templateCard!.color)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveCard(_ sender: Any) {
        let realm = RealmInstance.getInstance()
        
        let cardTitle = cardNameField.text
        
        if cardTitle == String() {
            showSimpleAlert(withTitle: "Название не указано", withMessage: "Введите название визитки!", inController: self)
            return
        }
        
        let cardTitleList = realm.objects(Card.self).map { $0.title }
        if cardTitle != templateCard?.title && cardTitleList.contains(cardTitle!) {
            showSimpleAlert(
                withTitle: "Название занято",
                withMessage: "Визитка с таким названием уже существует!",
                inController: self
            )
            return
        }
        
        let company = Company(
            parentUuid: RealmInstance.getInstance().objects(User.self)[0].uuid,
            uuid: templateCard?.cardUuid ?? UUID().uuidString,
            name: companyNameField.text ?? String(),
            responsibleFullName: responsibleNameField.text ?? String(),
            responsibleJobTitle: responsibleJobTitleField.text ?? String(),
            address: companyAddressField.text ?? String(),
            phone: companyPhoneField.text ?? String(),
            email: companyEmailField.text ?? String(),
            website: companySiteField.text ?? String()
        )
        let businessCard = BusinessCard<Company>(type: .company, data: company)
        
        FirestoreInstance.getInstance().collection(FirestoreInstance.USERS)
            .document(company.parentUuid)
            .collection(FirestoreInstance.CARDS)
            .document(company.uuid)
            .setData(JsonUtils.convertToDictionary(object: businessCard))
        
        if templateCard == nil {
            try! realm.write {
                realm.add(IdPair(parentUuid: company.parentUuid, uuid: company.uuid))
            }
        }
        
        let card = Card()
        card.uuid = templateCard?.uuid ?? UUID().uuidString
        card.type = CardType.company.rawValue
        card.color = (tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.imageView?.tintColor.toHexString())!
        card.title = cardNameField.text!
        card.cardUuid = company.uuid

        try! realm.write {
            if templateCard != nil {
                realm.add(card, update: .all)
                return
            }
            realm.add(card)
        }
        
        closeWindow(self)
        
        // Получение TemplatesController (Nav -> Tab -> Nav -> Cards)
        navigationController?.presentingViewController?.children.first?.children.first?.viewWillAppear(true)
        if templateCard != nil {
            navigationController?.presentingViewController?.children.first?.viewDidLoad()
        }
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 7
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "СВОЙСТВА ВИЗИТКИ" : "ДАННЫЕ ВИЗИТКИ"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
            cardColor = COLORS[Int.random(in: 0..<COLORS.count)]
            cell?.imageView?.tintColor = UIColor.init(hexString: cardColor)
            tableView.deselectSelectedRows(animated: true)
        }
    }
}

extension CreateCardCompanyController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = view.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
   }
}
