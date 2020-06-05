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
        if (user.sberbank != "") { data.append(DataItem(title: "Сбербанк (расчетный счет)", description: user.sberbank)) }
        if (user.vtb != "") { data.append(DataItem(title: "ВТБ (расчетный счет)", description: user.vtb)) }
        if (user.alfabank != "") { data.append(DataItem(title: "Альфа-Банк (расчетный счет)", description: user.alfabank)) }
        if (user.vk != "") { data.append(DataItem(title: "vk", description: user.vk)) }
        if (user.facebook != "") { data.append(DataItem(title: "facebook", description: user.facebook)) }
        if (user.instagram != "") { data.append(DataItem(title: "instagram", description: user.instagram)) }
        if (user.twitter != "") { data.append(DataItem(title: "twitter", description: user.twitter)) }
        if (user.notes != "") { data.append(DataItem(title: "заметки", description: user.notes)) }
        return data
    }
    
    static func parseDataToUser(data : [DataItem]) -> User {
        let user = User()
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
            if elem.title == "Сбербанк (расчетный счет)" { user.sberbank = elem.description }
            if elem.title == "ВТБ (расчетный счет)" { user.vtb = elem.description }
            if elem.title == "Альфа-Банк (расчетный счет)" { user.alfabank = elem.description }
            if elem.title == "vk" { user.vk = elem.description }
            if elem.title == "facebook" { user.facebook = elem.description }
            if elem.title == "instagram" { user.instagram = elem.description }
            if elem.title == "twitter" { user.twitter = elem.description }
            if elem.title == "заметки" { user.notes = elem.description }
        }
        return user
    }
    
    private static func checkForEmpty(field : String) -> Bool {
        return !field.isEmpty
    }
}
