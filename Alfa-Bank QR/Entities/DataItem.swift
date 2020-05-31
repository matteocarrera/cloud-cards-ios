//
//  DataItem.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 17.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation

class DataItem {
    var title : String = ""
    var description : String = ""
    var isSelected : Bool! = false
    
    init(title : String, description : String) {
        self.title = title
        self.description = description
    }
}
