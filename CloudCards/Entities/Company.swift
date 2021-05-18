/*
    Класс компании, используемый в визитках
 */

public class Company: Codable {
    
    // Родительский UUID, по которому можно обратиться к визитке
    var parentUuid: String
    
    // UUID компании
    var uuid: String
    
    // Наименование компании
    var name: String
    
    // ФИО ответственного от компании
    var responsibleFullName: String
    
    // Должность ответственного от компании
    var responsibleJobTitle: String
    
    // Адрес
    var address: String
    
    // Телефон
    var phone: String
    
    // Электронная почта
    var email: String
    
    // Сайт
    var website: String
    
    init(
        parentUuid: String,
        uuid: String,
        name: String,
        responsibleFullName: String,
        responsibleJobTitle: String,
        address: String,
        phone: String,
        email: String,
        website: String
    ) {
        self.parentUuid = parentUuid
        self.uuid = uuid
        self.name = name
        self.responsibleFullName = responsibleFullName
        self.responsibleJobTitle = responsibleJobTitle
        self.address = address
        self.phone = phone
        self.email = email
        self.website = website
    }
}
