import UIKit

/*
    Класс, хранящий в себе данные пользователя и его фотографию
 */

public class Contact: NSObject {
    
    // Пользователь с данными
    let user: User
    
    // Фотография пользователя
    let image: UIImage?
    
    init(user: User, image: UIImage?) {
        self.user = user
        self.image = image != nil ? image?.resizeWithPercent(percentage: 0.5) : nil
    }
}
