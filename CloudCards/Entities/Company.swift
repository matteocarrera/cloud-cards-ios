/*
    Класс компании, используемый в визитках
 */

public class Company: Codable {
    var name: String
    var responsibleFullName: String
    var responsibleJobTitle: String
    var address: String
    var mobile: String
    var email: String
    var website: String
}
