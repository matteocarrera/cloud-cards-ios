import UIKit

class Contact: NSObject {
    let user: User
    var image: UIImage?
    
    init(user: User, image: UIImage?) {
        self.user = user
        self.image = image != nil ? image?.resizeWithPercent(percentage: 0.5) : nil
    }
}
