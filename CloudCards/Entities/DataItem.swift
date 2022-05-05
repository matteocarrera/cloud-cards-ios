/*
    Класс элемента таблицы формата "описание поля/данные поля"
 */

public class DataItem {

    // Заголовок
    var title: String

    // Данные ячейки
    var data: String

    init(title: String, data: String) {
        self.title = title
        self.data = data
    }
}
