//
//  TestController.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 24.06.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import UIKit

class CardsController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var templatesView: UIView!
    @IBOutlet weak var contactsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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

    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                templatesView.isHidden = false
                contactsView.isHidden = true
            case 1:
                templatesView.isHidden = true
                contactsView.isHidden = false
            default:
                break;
        }
    }
    
}
