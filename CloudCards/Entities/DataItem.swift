import Foundation

/*
    Класс элемента таблицы формата "описание поля/данные поля"
 */

public class DataItem {
    var title : String = ""
    var data : String = ""
    
    init(title : String, data : String) {
        self.title = title
        self.data = data
    }
}
