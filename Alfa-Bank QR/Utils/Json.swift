//
//  Json.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 17.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation

class Json {
    static func toJson(user : User) -> String {
        return user.description
    }
    
    static func fromJson(json : String) -> User {
        let userData = json.split(separator: ",")
        let user = User()
        user.isScanned = 1
        user.name = String(userData[0])
        user.surname = String(userData[1])
        user.patronymic = String(userData[2])
        user.company = String(userData[3])
        user.jobTitle = String(userData[4])
        user.mobile = String(userData[5])
        user.mobileSecond = String(userData[6])
        user.email = String(userData[7])
        user.emailSecond = String(userData[8])
        user.address = String(userData[9])
        user.addressSecond = String(userData[10])
        user.sberbank = String(userData[11])
        user.vtb = String(userData[12])
        user.alfabank = String(userData[13])
        user.vk = String(userData[14])
        user.facebook = String(userData[15])
        user.instagram = String(userData[16])
        user.twitter = String(userData[17])
        user.name = String(userData[18])
        return user
    }
}
