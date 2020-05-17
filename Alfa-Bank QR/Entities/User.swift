//
//  User.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 17.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation

class User {
    var id : Int = 0
    var photo : [UInt8]? = []
    var qr : [UInt8]? = []
    var isOwner : Int = 0
    var isScanned : Int = 0
    var name : String = ""
    var surname : String = ""
    var patronymic : String = ""
    var company : String = ""
    var jobTitle : String = ""
    var mobile : String = ""
    var mobileSecond : String = ""
    var email : String = ""
    var emailSecond : String = ""
    var address : String = ""
    var addressSecond : String = ""
    var sberbank : String = ""
    var vtb : String = ""
    var alfabank : String = ""
    var vk : String = ""
    var facebook : String = ""
    var instagram : String = ""
    var twitter : String = ""
    var notes : String = ""
    
    public var description : String {return "\(name),\(surname),\(patronymic),\(company),\(jobTitle),\(mobile),\(mobileSecond),\(email),\(emailSecond),\(address),\(addressSecond),\(sberbank),\(vtb),\(alfabank),\(vk),\(facebook),\(instagram),\(twitter),\(notes)"}
}
