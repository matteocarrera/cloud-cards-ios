import Foundation
import UIKit

public func setDataToList(from user: User) -> [DataItem]{
    var data = [DataItem]()
    if (user.surname != "") { data.append(DataItem(title: SURNAME, data: user.surname)) }
    if (user.name != "") { data.append(DataItem(title: NAME, data: user.name)) }
    if (user.patronymic != "") { data.append(DataItem(title: PATRONYMIC, data: user.patronymic)) }
    if (user.company != "") { data.append(DataItem(title: COMPANY, data: user.company)) }
    if (user.jobTitle != "") { data.append(DataItem(title: JOB_TITLE, data: user.jobTitle)) }
    if (user.mobile != "") { data.append(DataItem(title: MOBILE, data: user.mobile)) }
    if (user.mobileSecond != "") { data.append(DataItem(title: MOBILE_OTHER, data: user.mobileSecond)) }
    if (user.email != "") { data.append(DataItem(title: EMAIL, data: user.email)) }
    if (user.emailSecond != "") { data.append(DataItem(title: EMAIL_OTHER, data: user.emailSecond)) }
    if (user.address != "") { data.append(DataItem(title: ADDRESS, data: user.address)) }
    if (user.addressSecond != "") { data.append(DataItem(title: ADDRESS_OTHER, data: user.addressSecond)) }
    if (user.cardNumber != "") { data.append(DataItem(title: CARD_NUMBER, data: user.cardNumber)) }
    if (user.cardNumberSecond != "") { data.append(DataItem(title: CARD_NUMBER_SECOND, data: user.cardNumberSecond)) }
    if (user.website != "") { data.append(DataItem(title: WEBSITE, data: user.website)) }
    if (user.vk != "") { data.append(DataItem(title: VK, data: user.vk)) }
    if (user.telegram != "") { data.append(DataItem(title: TELEGRAM, data: user.telegram)) }
    if (user.facebook != "") { data.append(DataItem(title: FACEBOOK, data: user.facebook)) }
    if (user.instagram != "") { data.append(DataItem(title: INSTAGRAM, data: user.instagram)) }
    if (user.twitter != "") { data.append(DataItem(title: TWITTER, data: user.twitter)) }
    if (user.notes != "") { data.append(DataItem(title: NOTES, data: user.notes)) }
    return data
}

public func parseDataToUserBoolean(from data: [DataItem]) -> UserBoolean {
    let user = UserBoolean()
    for elem in data {
        if elem.title == SURNAME { user.surname = true }
        if elem.title == NAME { user.name = true }
        if elem.title == PATRONYMIC { user.patronymic = true }
        if elem.title == COMPANY { user.company = true }
        if elem.title == JOB_TITLE { user.jobTitle = true }
        if elem.title == MOBILE { user.mobile = true }
        if elem.title == MOBILE_OTHER { user.mobileSecond = true }
        if elem.title == EMAIL { user.email = true }
        if elem.title == EMAIL_OTHER { user.emailSecond = true }
        if elem.title == ADDRESS { user.address = true }
        if elem.title == ADDRESS_OTHER { user.addressSecond = true }
        if elem.title == CARD_NUMBER { user.cardNumber = true }
        if elem.title == CARD_NUMBER_SECOND { user.cardNumberSecond = true }
        if elem.title == WEBSITE { user.website = true }
        if elem.title == VK { user.vk = true }
        if elem.title == TELEGRAM { user.telegram = true }
        if elem.title == FACEBOOK { user.facebook = true }
        if elem.title == INSTAGRAM { user.instagram = true }
        if elem.title == TWITTER { user.twitter = true }
        if elem.title == NOTES { user.notes = true }
    }
    return user
}

public func parseDataToUser(from data: [DataItem]) -> User {
    let user = User()
    for elem in data {
        if elem.title == SURNAME { user.surname = elem.data }
        if elem.title == NAME { user.name = elem.data }
        if elem.title == PATRONYMIC { user.patronymic = elem.data }
        if elem.title == COMPANY { user.company = elem.data }
        if elem.title == JOB_TITLE { user.jobTitle = elem.data }
        if elem.title == MOBILE { user.mobile = elem.data }
        if elem.title == MOBILE_OTHER { user.mobileSecond = elem.data }
        if elem.title == EMAIL { user.email = elem.data }
        if elem.title == EMAIL_OTHER { user.emailSecond = elem.data }
        if elem.title == ADDRESS { user.address = elem.data }
        if elem.title == ADDRESS_OTHER { user.addressSecond = elem.data }
        if elem.title == CARD_NUMBER { user.cardNumber = elem.data }
        if elem.title == CARD_NUMBER_SECOND { user.cardNumberSecond = elem.data }
        if elem.title == WEBSITE { user.website = elem.data }
        if elem.title == VK { user.vk = elem.data }
        if elem.title == TELEGRAM { user.telegram = elem.data }
        if elem.title == FACEBOOK { user.facebook = elem.data }
        if elem.title == INSTAGRAM { user.instagram = elem.data }
        if elem.title == TWITTER { user.twitter = elem.data }
        if elem.title == NOTES { user.notes = elem.data }
    }
    return user
}

public func getUserFromTemplate(user: User, userBoolean: UserBoolean) -> User {
    let currentUser = User()
    currentUser.parentId = userBoolean.parentId
    currentUser.uuid = userBoolean.uuid
    currentUser.photo = user.photo != "" ? user.photo : ""
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

public func sortContacts(in viewController: UIViewController, with contactsOptional: [Contact]? = nil, by field: Field) {
    let controller = viewController as! ContactsController
    var contacts = [Contact]()
    
    // Если в аргументы не передали список контактов, то словарь изначально имеет в себе значения, иначе значения только загружались из Firebase
    if contactsOptional == nil {
        controller.contactsDictionary.values.forEach { users in
            contacts.append(contentsOf: users)
        }
    } else {
        contacts = contactsOptional!
    }
    
    controller.contactsDictionary.removeAll()
    
    // Добавление контакта в словарь
    contacts.forEach { contact in
        let contactKey: String
        
        switch field {
        case .name:
            contactKey = String(contact.user.name.prefix(1))
        case .surname:
            contactKey = String(contact.user.surname.prefix(1))
        case .company:
            contactKey = String(contact.user.company.prefix(1))
        case .jobTitle:
            contactKey = String(contact.user.jobTitle.prefix(1))
        }
        
        if var contactValues = controller.contactsDictionary[contactKey] {
            contactValues.append(contact)
            controller.contactsDictionary[contactKey] = contactValues
        } else {
            controller.contactsDictionary[contactKey] = [contact]
        }
    }
    
    // Сортировка каждого массива контактов по секциям
    for key in controller.contactsDictionary.keys {
        switch field {
        case .name:
            controller.contactsDictionary[key]?.sort(by: {$0.user.name < $1.user.name})
        case .surname:
            controller.contactsDictionary[key]?.sort(by: {$0.user.surname < $1.user.surname})
        case .company:
            controller.contactsDictionary[key]?.sort(by: {$0.user.company < $1.user.company})
        case .jobTitle:
            controller.contactsDictionary[key]?.sort(by: {$0.user.jobTitle < $1.user.jobTitle})
        }
    }
    
    // Создание массива букв для секций таблицы, сортировка
    controller.contactsSectionTitles = [String](controller.contactsDictionary.keys)
    controller.contactsSectionTitles = controller.contactsSectionTitles.sorted(by: {$0 < $1})
    
    controller.contactsTable.reloadData()
}

private func checkField(field: String, isSelected: Bool) -> String {
    return (isSelected) ? field : String()
}
