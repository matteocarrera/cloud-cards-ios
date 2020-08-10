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
    
    static func parseDataToUserBoolean(data : [DataItem]) -> UserBoolean {
        let user = UserBoolean()
        for elem in data {
            if elem.title == "фамилия" { user.surname = true }
            if elem.title == "имя" { user.name = true }
            if elem.title == "отчество" { user.patronymic = true }
            if elem.title == "компания" { user.company = true }
            if elem.title == "должность" { user.jobTitle = true }
            if elem.title == "мобильный номер" { user.mobile = true }
            if elem.title == "мобильный номер (другой)" { user.mobileSecond = true }
            if elem.title == "email" { user.email = true }
            if elem.title == "email (другой)" { user.emailSecond = true }
            if elem.title == "адрес" { user.address = true }
            if elem.title == "адрес (другой)" { user.addressSecond = true }
            if elem.title == "номер карты 1" { user.cardNumber = true }
            if elem.title == "номер карты 2" { user.cardNumberSecond = true }
            if elem.title == "сайт" { user.website = true }
            if elem.title == "vk" { user.vk = true }
            if elem.title == "telegram" { user.telegram = true }
            if elem.title == "facebook" { user.facebook = true }
            if elem.title == "instagram" { user.instagram = true }
            if elem.title == "twitter" { user.twitter = true }
            if elem.title == "заметки" { user.notes = true }
        }
        return user
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
    
    static func generatedUsersEqual(firstUser : UserBoolean, secondUser : UserBoolean) -> Bool {
        return firstUser.name == secondUser.name &&
            firstUser.surname == secondUser.surname &&
            firstUser.patronymic == secondUser.patronymic &&
            firstUser.company == secondUser.company &&
            firstUser.jobTitle == secondUser.jobTitle &&
            firstUser.mobile == secondUser.mobile &&
            firstUser.mobileSecond == secondUser.mobileSecond &&
            firstUser.email == secondUser.email &&
            firstUser.emailSecond == secondUser.emailSecond &&
            firstUser.address == secondUser.address &&
            firstUser.addressSecond == secondUser.addressSecond &&
            firstUser.cardNumber == secondUser.cardNumber &&
            firstUser.cardNumberSecond == secondUser.cardNumberSecond &&
            firstUser.website == secondUser.website &&
            firstUser.vk == secondUser.vk &&
            firstUser.telegram == secondUser.telegram &&
            firstUser.facebook == secondUser.facebook &&
            firstUser.instagram == secondUser.instagram &&
            firstUser.twitter == secondUser.twitter &&
            firstUser.notes == secondUser.notes
    }
    
    static func getUserFromTemplate(user : User, userBoolean : UserBoolean) -> User {
        let currentUser = User()
        currentUser.parentId = userBoolean.parentId
        currentUser.uuid = userBoolean.uuid
        currentUser.name = checkField(field: user.name, isSelected: userBoolean.name)
        currentUser.surname = checkField(field: user.surname, isSelected: userBoolean.surname)
        currentUser.patronymic = checkField(field: user.patronymic, isSelected: userBoolean.patronymic)
        currentUser.company = checkField(field: user.company, isSelected: userBoolean.company)
        currentUser.jobTitle = checkField(field: user.jobTitle, isSelected: userBoolean.jobTitle)
        currentUser.mobile = checkField(field: user.mobile, isSelected: userBoolean.mobile)
        currentUser.mobileSecond = checkField(field: user.mobileSecond, isSelected: userBoolean.mobileSecond)
        currentUser.email = checkField(field: user.email, isSelected: userBoolean.email)
        currentUser.emailSecond = checkField(field: user.emailSecond, isSelected: userBoolean.emailSecond)
        currentUser.address = checkField(field: user.address, isSelected: userBoolean.address)
        currentUser.addressSecond = checkField(field: user.addressSecond, isSelected: userBoolean.addressSecond)
        currentUser.cardNumber = checkField(field: user.cardNumber, isSelected: userBoolean.cardNumber)
        currentUser.cardNumberSecond = checkField(field: user.cardNumberSecond, isSelected: userBoolean.cardNumberSecond)
        currentUser.website = checkField(field: user.website, isSelected: userBoolean.website)
        currentUser.vk = checkField(field: user.vk, isSelected: userBoolean.vk)
        currentUser.telegram = checkField(field: user.telegram, isSelected: userBoolean.telegram)
        currentUser.facebook = checkField(field: user.facebook, isSelected: userBoolean.facebook)
        currentUser.instagram = checkField(field: user.instagram, isSelected: userBoolean.instagram)
        currentUser.twitter = checkField(field: user.twitter, isSelected: userBoolean.twitter)
        currentUser.notes = checkField(field: user.notes, isSelected: userBoolean.notes)
        return currentUser
    }
    
    private static func checkField(field : String, isSelected : Bool) -> String {
        if isSelected {
            return field
        } else {
            return ""
        }
    }
    
    private static func checkForEmpty(field : String) -> Bool {
        return !field.isEmpty
    }
}
