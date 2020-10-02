//
//  JsonUtils.swift
//  Alfa-Bank QR
//
//  Created by Владимир Макаров on 01.10.2020.
//  Copyright © 2020 Vladimir Makarov. All rights reserved.
//

import Foundation

public func convertToJson<T:Encodable>(someUser : T) -> String {
    let jsonEncoder = JSONEncoder()
    let jsonData = try! jsonEncoder.encode(someUser)
    let json = String(data: jsonData, encoding: String.Encoding.utf8)!
    
    return json
}

public func convertFromJson<T:Decodable>(json : String, type : T.Type) -> T {
    let jsonData = json.data(using: .utf8)!
    let user = try! JSONDecoder().decode(type, from: jsonData)
    
    return user
}
