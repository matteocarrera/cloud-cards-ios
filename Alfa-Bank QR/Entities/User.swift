//
//  User.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 17.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation
import RealmSwift

class User : Object {
    @objc dynamic var id : Int = 0
    @objc dynamic var photo : String = ""
    @objc dynamic var qr : NSData?
    @objc dynamic var isOwner : Int = 0
    @objc dynamic var isScanned : Int = 0
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
    @objc dynamic var sberbank : String = ""
    @objc dynamic var vtb : String = ""
    @objc dynamic var alfabank : String = ""
    @objc dynamic var vk : String = ""
    @objc dynamic var facebook : String = ""
    @objc dynamic var instagram : String = ""
    @objc dynamic var twitter : String = ""
    @objc dynamic var notes : String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
