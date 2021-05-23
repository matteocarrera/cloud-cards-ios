//
//  ApiClient.swift
//  CloudCards
//
//  Created by Владимир Макаров on 29.01.2021.
//  Copyright © 2021 Vladimir Makarov. All rights reserved.
//

import Foundation
import UIKit

enum FirebaseError: Error {
    case invalidUrl
    case invalidData
    case invalidDocument
}

protocol FirebaseClient {
    func getUser(idPair: IdPair, pathToData: Bool, completion: @escaping (Result<[String: Any], Error>) -> ())
    func getPhoto(with photoId: String, completion: @escaping (Result<UIImage, Error>) -> ())
}

class FirebaseClientImpl: FirebaseClient {
    func getUser(idPair: IdPair, pathToData: Bool = false, completion: @escaping (Result<[String: Any], Error>) -> ()) {
        let secondKey = pathToData == true ? FirestoreInstance.DATA : FirestoreInstance.CARDS
        let db = FirestoreInstance.getInstance()
        db.collection(FirestoreInstance.USERS)
            .document(idPair.parentUuid)
            .collection(secondKey)
            .document(idPair.uuid)
            .getDocument { (document, error) in
                if let document = document, document.exists {
                    guard let data = document.data() else {
                        completion(.failure(FirebaseError.invalidData))
                        return
                    }
                    
                    completion(.success(data))
                    return
                }
                completion(.failure(FirebaseError.invalidDocument))
                return
            }
    }
    
    func getPhoto(with photoId: String, completion: @escaping (Result<UIImage, Error>) -> ()) {
        let urlString = "https://firebasestorage.googleapis.com/v0/b/cloudcardsmobile.appspot.com/o/\(photoId)?alt=media"
        guard let url = URL(string: urlString) else {
            completion(.failure(FirebaseError.invalidUrl))
            return
        }
        
        let data = try? Data(contentsOf: url)
        
        if let data = data {
            guard let image = UIImage(data: data) else {
                completion(.failure(FirebaseError.invalidData))
                return
            }
            completion(.success(image))
            return
        }
    }
}
