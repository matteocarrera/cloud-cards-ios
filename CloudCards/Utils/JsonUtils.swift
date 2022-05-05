import Foundation

public class JsonUtils {

    class func convertToDictionary<T: Encodable>(object: T) -> [String: Any] {
        let jsonData = try! JSONEncoder().encode(object)
        let data = try! JSONSerialization.jsonObject(with: jsonData, options: [])

        return data as! [String: Any]
    }

    class func convertFromDictionary<T: Decodable>(dictionary: [String: Any], type: T.Type) -> T {
        let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        let user = try! JSONDecoder().decode(type, from: jsonData)

        return user
    }

}
