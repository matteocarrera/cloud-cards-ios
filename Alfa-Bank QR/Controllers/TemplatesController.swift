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
        
        viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        templates.removeAll()
        
        let realm = try! Realm()

        templates = Array(realm.objects(Card.self))
        
        let defaults = UserDefaults(suiteName: "group.urfusoftware.Alfa-Bank-QR")
        let link = defaults?.string(forKey: "link")
        
        if link != nil || ((link?.contains("|")) != nil) {
            DataBaseUtils.saveUser(controller: self, link: link!)
        }

        defaults?.removeObject(forKey: "link")
        
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

        showQR(userId: dataCell.userId)
        
        templatesTable.reloadData()
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
        
        alert.addAction(UIAlertAction.init(title: "Открыть", style: .default, handler: { (_) in
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
            viewController.userId = card.userId
            self.navigationController?.pushViewController(viewController, animated: true)
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
    
    private func showQR(userId : String) {
        let showAlert = UIAlertController(title: "QR-визитка", message: nil, preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 250, height: 250))
        
        let realm = try! Realm()
        
        let owner = realm.objects(User.self)[0]
        let userLink = owner.uuid + "|" + userId
        
        imageView.image = ProgramUtils.generateQR(userLink: userLink)
        showAlert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: showAlert.view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 360)
        let width = NSLayoutConstraint(item: showAlert.view as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        showAlert.view.addConstraint(height)
        showAlert.view.addConstraint(width)
        showAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
        if #available(iOS 13.0, *) {
            showAlert.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        }
        self.present(showAlert, animated: true, completion: nil)
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
