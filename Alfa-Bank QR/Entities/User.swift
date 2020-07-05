//
//  User.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 17.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation
import RealmSwift

class User : Object, Codable {
    @objc dynamic var id : String = ""
    @objc dynamic var photo : String = ""
    @objc dynamic var isOwner : Bool = false
    @objc dynamic var isScanned : Bool = false
    @objc dynamic var name : String = ""
    @objc dynamic var surname : String = ""
    @objc dynamic var patronymic : String = ""
    @objc dynamic var company : String = ""
    @objc dynamic var jobTitle : String = ""
    @objc dynamic var mobile : String = ""
    @objc dynamic var mobileSecond : String = ""
    @objc dynamic var email : String = ""
    @objc dynamic var emailSecond : String = ""
    @objc dynamic var address : String = ""
    @objc dynamic var addressSecond : String = ""
    @objc dynamic var cardNumber : String = ""
    @objc dynamic var cardNumberSecond : String = ""
    @objc dynamic var website : String = ""
    @objc dynamic var vk : String = ""
    @objc dynamic var telegram : String = ""
    @objc dynamic var facebook : String = ""
    @objc dynamic var instagram : String = ""
    @objc dynamic var twitter : String = ""
    @objc dynamic var notes : String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
