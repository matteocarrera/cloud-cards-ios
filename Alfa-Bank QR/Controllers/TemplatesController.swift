//
//  TemplatesController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 20.07.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import FirebaseDatabase
import RealmSwift

class TemplatesController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var templatesTable: UITableView!
    var templates = [Card]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableUtils.configureTableView(table: templatesTable, controller: self)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPressGestureRecognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        templates.removeAll()
        
        let realm = try! Realm()

        templates = Array(realm.objects(Card.self))
        
        templatesTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = templatesTable.dequeueReusableCell(withIdentifier: "TemplatesCell", for: indexPath) as! TemplatesCell
        
        let dataCell = templates[indexPath.row]
        cell.title.text = dataCell.title
        cell.color.backgroundColor = UIColor(hexString: dataCell.color)
        cell.userId = dataCell.userId
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = templates[indexPath.row]
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
        viewController.userId = dataCell.userId
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let index = self.templatesTable.indexPathForRow(at: touchPoint)  {
                let card = templates[index.row]
                showCardMenu(card: card)
            }
        }
    }
    
    private func showCardMenu(card : Card) {
        let alert = UIAlertController.init(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)
        
        let realm = try! Realm()
        
        alert.addAction(UIAlertAction.init(title: "QR код", style: .default, handler: { (_) in
            
            let qrController = self.storyboard?.instantiateViewController(withIdentifier: "QRController") as! QRController
            
            let owner = realm.objects(User.self)[0]
            let userLink = owner.uuid + "|" + card.userId

            qrController.userLink = userLink
            
            self.navigationController?.pushViewController(qrController, animated: true)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Поделиться", style: .default, handler: { (_) in
            
            let owner = realm.objects(User.self)[0]
            let userLink = owner.uuid + "|" + card.userId

            if let image = ProgramUtils.generateQR(userLink: userLink) {
                let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
                self.present(vc, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction.init(title: "Удалить", style: .default, handler: { (_) in
            try! realm.write {
                realm.delete(card)
            }
            
            self.viewWillAppear(true)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
            
        self.present(alert, animated: true)
    }
}

class TemplatesCell : UITableViewCell {
    
    @IBOutlet weak var color : UIView!
    @IBOutlet weak var title : UILabel!
    var userId : String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TableUtils.setColorToSelectedRow(tableCell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
