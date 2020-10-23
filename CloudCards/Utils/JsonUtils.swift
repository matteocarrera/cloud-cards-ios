import Foundation

public func convertToDictionary<T:Encodable>(someUser : T) -> [String : Any] {
    let jsonEncoder = JSONEncoder()
    let jsonData = try! jsonEncoder.encode(someUser)
    //let json = String(data: jsonData, encoding: String.Encoding.utf8)!
    let data = try! JSONSerialization.jsonObject(with: jsonData, options: [])
    
    return data as! [String : Any]
}

public func convertFromDictionary<T:Decodable>(dictionary : [String : Any], type : T.Type) -> T {
    let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
    //let jsonData = json.data(using: .utf8)!
    let user = try! JSONDecoder().decode(type, from: jsonData)
    
    return user
}
