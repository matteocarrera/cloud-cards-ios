import Foundation

public class JsonUtils {

    class func convertToDictionary<T: Encodable>(object: T) -> [String: Any] {
        guard let jsonData = try? JSONEncoder().encode(object),
              let data = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let dataDictionary = data as? [String: Any] else {
            return [:]
        }

        return dataDictionary
    }

    // swiftlint:disable force_try
    class func convertFromDictionary<T: Decodable>(dictionary: [String: Any], type: T.Type) -> T {
        let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        let user = try! JSONDecoder().decode(type, from: jsonData)

        return user
    }

}
