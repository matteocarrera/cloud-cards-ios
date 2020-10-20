import Foundation

class DataItem {
    var title : String = ""
    var description : String = ""
    var isSelected : Bool! = false
    
    init(title : String, description : String) {
        self.title = title
        self.description = description
    }
}
