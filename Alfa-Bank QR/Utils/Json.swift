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
        return  "\(user.photo)|\(user.name)|\(user.surname)|\(user.patronymic)|\(user.company)|\(user.jobTitle)|\(user.mobile)|\(user.mobileSecond)|\(user.email)|\(user.emailSecond)|\(user.address)|\(user.addressSecond)|\(user.sberbank)|\(user.vtb)|\(user.alfabank)|\(user.vk)|\(user.facebook)|\(user.instagram)|\(user.twitter)|\(user.notes)"
    }
    
    static func fromJson(json : String) -> User {
        let userData = json.split(separator: "|", omittingEmptySubsequences: false)
        let user = User()
        user.isScanned = 1
        user.photo = String(userData[0])
        user.name = String(userData[1])
        user.surname = String(userData[2])
        user.patronymic = String(userData[3])
        user.company = String(userData[4])
        user.jobTitle = String(userData[5])
        user.mobile = String(userData[6])
        user.mobileSecond = String(userData[7])
        user.email = String(userData[8])
        user.emailSecond = String(userData[9])
        user.address = String(userData[10])
        user.addressSecond = String(userData[11])
        user.sberbank = String(userData[12])
        user.vtb = String(userData[13])
        user.alfabank = String(userData[14])
        user.vk = String(userData[15])
        user.facebook = String(userData[16])
        user.instagram = String(userData[17])
        user.twitter = String(userData[18])
        user.notes = String(userData[19])
        return user
    }
}
