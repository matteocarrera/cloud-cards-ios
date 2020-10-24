import Foundation

public func convertToDictionary<T:Encodable>(someUser : T) -> [String : Any] {
    let jsonEncoder = JSONEncoder()
    let jsonData = try! jsonEncoder.encode(someUser)
    let data = try! JSONSerialization.jsonObject(with: jsonData, options: [])
    
    return data as! [String : Any]
}

public func convertFromDictionary<T:Decodable>(dictionary : [String : Any], type : T.Type) -> T {
    let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
    let user = try! JSONDecoder().decode(type, from: jsonData)
    
    return user
}
