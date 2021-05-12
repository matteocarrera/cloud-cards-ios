/*
    Класс визитки, содержащий в себе тип и сами данные контакта (персональная или компания)
 */

public class BusinessCard: Codable {
    var type: CardType
    var data: [String: String]

    init(type: CardType, data: [String: String]) {
        self.type = type
        self.data = data
    }
}
