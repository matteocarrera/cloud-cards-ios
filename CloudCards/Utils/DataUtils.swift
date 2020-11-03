import Foundation

func setDataToList(user : User) -> [DataItem]{
    var data = [DataItem]()
    if (user.surname != "") { data.append(DataItem(title: SURNAME, description: user.surname)) }
    if (user.name != "") { data.append(DataItem(title: NAME, description: user.name)) }
    if (user.patronymic != "") { data.append(DataItem(title: PATRONYMIC, description: user.patronymic)) }
    if (user.company != "") { data.append(DataItem(title: COMPANY, description: user.company)) }
    if (user.jobTitle != "") { data.append(DataItem(title: JOB_TITLE, description: user.jobTitle)) }
    if (user.mobile != "") { data.append(DataItem(title: MOBILE, description: user.mobile)) }
    if (user.mobileSecond != "") { data.append(DataItem(title: MOBILE_OTHER, description: user.mobileSecond)) }
    if (user.email != "") { data.append(DataItem(title: EMAIL, description: user.email)) }
    if (user.emailSecond != "") { data.append(DataItem(title: EMAIL_OTHER, description: user.emailSecond)) }
    if (user.address != "") { data.append(DataItem(title: ADDRESS, description: user.address)) }
    if (user.addressSecond != "") { data.append(DataItem(title: ADDRESS_OTHER, description: user.addressSecond)) }
    if (user.cardNumber != "") { data.append(DataItem(title: CARD_NUMBER, description: user.cardNumber)) }
    if (user.cardNumberSecond != "") { data.append(DataItem(title: CARD_NUMBER_SECOND, description: user.cardNumberSecond)) }
    if (user.website != "") { data.append(DataItem(title: WEBSITE, description: user.website)) }
    if (user.vk != "") { data.append(DataItem(title: VK, description: user.vk)) }
    if (user.telegram != "") { data.append(DataItem(title: TELEGRAM, description: user.telegram)) }
    if (user.facebook != "") { data.append(DataItem(title: FACEBOOK, description: user.facebook)) }
    if (user.instagram != "") { data.append(DataItem(title: INSTAGRAM, description: user.instagram)) }
    if (user.twitter != "") { data.append(DataItem(title: TWITTER, description: user.twitter)) }
    if (user.notes != "") { data.append(DataItem(title: NOTES, description: user.notes)) }
    return data
}

func parseDataToUserBoolean(data : [DataItem]) -> UserBoolean {
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

func parseDataToUser(data : [DataItem]) -> User {
    let user = User()
    for elem in data {
        if elem.title == SURNAME { user.surname = elem.description }
        if elem.title == NAME { user.name = elem.description }
        if elem.title == PATRONYMIC { user.patronymic = elem.description }
        if elem.title == COMPANY { user.company = elem.description }
        if elem.title == JOB_TITLE { user.jobTitle = elem.description }
        if elem.title == MOBILE { user.mobile = elem.description }
        if elem.title == MOBILE_OTHER { user.mobileSecond = elem.description }
        if elem.title == EMAIL { user.email = elem.description }
        if elem.title == EMAIL_OTHER { user.emailSecond = elem.description }
        if elem.title == ADDRESS { user.address = elem.description }
        if elem.title == ADDRESS_OTHER { user.addressSecond = elem.description }
        if elem.title == CARD_NUMBER { user.cardNumber = elem.description }
        if elem.title == CARD_NUMBER_SECOND { user.cardNumberSecond = elem.description }
        if elem.title == WEBSITE { user.website = elem.description }
        if elem.title == VK { user.vk = elem.description }
        if elem.title == TELEGRAM { user.telegram = elem.description }
        if elem.title == FACEBOOK { user.facebook = elem.description }
        if elem.title == INSTAGRAM { user.instagram = elem.description }
        if elem.title == TWITTER { user.twitter = elem.description }
        if elem.title == NOTES { user.notes = elem.description }
    }
    return user
}

func generatedUsersEqual(firstUser : UserBoolean, secondUser : UserBoolean) -> Bool {
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

func getUserFromTemplate(user : User, userBoolean : UserBoolean) -> User {
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

private func checkField(field : String, isSelected : Bool) -> String {
    if isSelected {
        return field
    } else {
        return ""
    }
}
