//
//  Card.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 17.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation
import RealmSwift

class Card : Object {
    @objc dynamic var id : Int = 0
    @objc dynamic var color : Int = 0
    @objc dynamic var title : String = ""
    @objc dynamic var userId : Int = 0
}
