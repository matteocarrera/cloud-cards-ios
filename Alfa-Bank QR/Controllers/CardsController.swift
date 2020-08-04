//
//  TestController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 24.06.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit
import RealmSwift

class CardsController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var selectButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var templatesView: UIView!
    @IBOutlet weak var contactsView: UIView!
    public var selectionIsActivated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .normal)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        shareButton.tintColor = UIColor(hexString: "#0B1F35")
        shareButton.isEnabled = false
        
        selectionIsActivated = false
        
        indexChanged(segmentedControl)
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func selectMultiple(_ sender: Any) {
        if selectionIsActivated {
            cancelSelection()
        } else {
            let cancelButton : UIBarButtonItem = UIBarButtonItem(title: "Отменить", style: UIBarButtonItem.Style.plain, target: self, action: #selector(selectMultiple(_:)))
            cancelButton.tintColor = UIColor.white

            self.navigationItem.rightBarButtonItem = cancelButton
            
            selectionIsActivated = true
            shareButton.tintColor = UIColor(hexString: "#FFFFFF")
            shareButton.isEnabled = true
        }
    }
    
    @IBAction func openMenu(_ sender: Any) {
        let alert = UIAlertController.init(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction.init(title: "Поделиться", style: .default, handler: { (_) in
            self.cancelSelection()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Удалить", style: .default, handler: { (_) in
            let child = self.children[1] as! ContactsController
            
            let realm = try! Realm()
            
            for uuid in child.selectedContactsUuid {
                let contact = realm.objects(UserBoolean.self).filter("uuid = \"\(uuid)\"")[0]
                
                try! realm.write {
                    realm.delete(contact)
                }
            }
            
            self.cancelSelection()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
            
        self.present(alert, animated: true)
        
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                templatesView.isHidden = false
                contactsView.isHidden = true
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            case 1:
                templatesView.isHidden = true
                contactsView.isHidden = false
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            default:
                break;
        }
    }
    
    private func cancelSelection() {
        let child = children[1] as! ContactsController
        
        let select : UIBarButtonItem = UIBarButtonItem(image: selectButton.image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(selectMultiple(_:)))
        select.tintColor = UIColor.white

        self.navigationItem.rightBarButtonItem = select
        
        child.viewWillAppear(true)
        selectionIsActivated = false
        shareButton.tintColor = UIColor(hexString: "#0B1F35")
        shareButton.isEnabled = false
    }
    
}
