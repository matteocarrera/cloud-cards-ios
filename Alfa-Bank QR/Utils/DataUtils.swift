//
//  DataUtils.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 30.05.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation

class DataUtils {
    static func setDataToList(user : User) -> [DataItem]{
        var data = [DataItem]()
        if (user.surname != "") { data.append(DataItem(title: "фамилия", description: user.surname)) }
        if (user.name != "") { data.append(DataItem(title: "имя", description: user.name)) }
        if (user.patronymic != "") { data.append(DataItem(title: "отчество", description: user.patronymic)) }
        if (user.company != "") { data.append(DataItem(title: "компания", description: user.company)) }
        if (user.jobTitle != "") { data.append(DataItem(title: "должность", description: user.jobTitle)) }
        if (user.mobile != "") { data.append(DataItem(title: "мобильный номер", description: user.mobile)) }
        if (user.mobileSecond != "") { data.append(DataItem(title: "мобильный номер (другой)", description: user.mobileSecond)) }
        if (user.email != "") { data.append(DataItem(title: "email", description: user.email)) }
        if (user.emailSecond != "") { data.append(DataItem(title: "email (другой)", description: user.emailSecond)) }
        if (user.address != "") { data.append(DataItem(title: "адрес", description: user.address)) }
        if (user.addressSecond != "") { data.append(DataItem(title: "адрес (другой)", description: user.addressSecond)) }
        if (user.cardNumber != "") { data.append(DataItem(title: "номер карты 1", description: user.cardNumber)) }
        if (user.cardNumberSecond != "") { data.append(DataItem(title: "номер карты 2", description: user.cardNumberSecond)) }
        if (user.website != "") { data.append(DataItem(title: "сайт", description: user.website)) }
        if (user.vk != "") { data.append(DataItem(title: "vk", description: user.vk)) }
        if (user.telegram != "") { data.append(DataItem(title: "telegram", description: user.telegram)) }
        if (user.facebook != "") { data.append(DataItem(title: "facebook", description: user.facebook)) }
        if (user.instagram != "") { data.append(DataItem(title: "instagram", description: user.instagram)) }
        if (user.twitter != "") { data.append(DataItem(title: "twitter", description: user.twitter)) }
        if (user.notes != "") { data.append(DataItem(title: "заметки", description: user.notes)) }
        return data
    }
    
    static func parseDataToUser(data : [DataItem]) -> User {
        let user = User()
        user.isScanned = false
        user.isOwner = false
        for elem in data {
            if elem.title == "фамилия" { user.surname = elem.description }
            if elem.title == "имя" { user.name = elem.description }
            if elem.title == "отчество" { user.patronymic = elem.description }
            if elem.title == "компания" { user.company = elem.description }
            if elem.title == "должность" { user.jobTitle = elem.description }
            if elem.title == "мобильный номер" { user.mobile = elem.description }
            if elem.title == "мобильный номер (другой)" { user.mobileSecond = elem.description }
            if elem.title == "email" { user.email = elem.description }
            if elem.title == "email (другой)" { user.emailSecond = elem.description }
            if elem.title == "адрес" { user.address = elem.description }
            if elem.title == "адрес (другой)" { user.addressSecond = elem.description }
            if elem.title == "номер карты 1" { user.cardNumber = elem.description }
            if elem.title == "номер карты 2" { user.cardNumberSecond = elem.description }
            if elem.title == "сайт" { user.website = elem.description }
            if elem.title == "vk" { user.vk = elem.description }
            if elem.title == "telegram" { user.telegram = elem.description }
            if elem.title == "facebook" { user.facebook = elem.description }
            if elem.title == "instagram" { user.instagram = elem.description }
            if elem.title == "twitter" { user.twitter = elem.description }
            if elem.title == "заметки" { user.notes = elem.description }
        }
        return user
    }
    
    static func userToString(user : User) -> String {
        return "\(user.surname)|\(user.name)|\(user.patronymic)|\(user.company)|\(user.jobTitle)|\(user.mobile)|\(user.mobileSecond)|\(user.email)|\(user.emailSecond)|\(user.address)|\(user.addressSecond)|\(user.cardNumber)|\(user.cardNumberSecond)|\(user.website)|\(user.vk)|\(user.telegram)|\(user.facebook)|\(user.instagram)|\(user.twitter)|\(user.notes)"
    }
    
    private static func checkForEmpty(field : String) -> Bool {
        return !field.isEmpty
    }
}
