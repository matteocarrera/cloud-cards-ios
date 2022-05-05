/*
    Класс визитки, содержащий в себе тип и сами данные контакта (персональная или компания)
 */

public class BusinessCard<T: Codable>: Codable {

    // Тип визитной карточки
    var type: CardType

    // Данные в формате словаря
    var data: T

    init(type: CardType, data: T) {
        self.type = type
        self.data = data
    }
}
