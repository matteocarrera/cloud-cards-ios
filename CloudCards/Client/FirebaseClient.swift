import UIKit
import Kingfisher

enum FirebaseError: Error {
    case invalidUrl
    case invalidData
    case invalidDocument
}

protocol FirebaseClient {
    func getUser(idPair: IdPair, pathToData: Bool, completion: @escaping (Result<[String: Any], Error>) -> Void)
    func getPhoto(setImageTo imageView: UIImageView, with photoId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class FirebaseClientImpl: FirebaseClient {
    func getUser(idPair: IdPair, pathToData: Bool = false, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let secondKey = pathToData == true ? FirestoreInstance.DATA : FirestoreInstance.CARDS
        let db = FirestoreInstance.getInstance()
        db.collection(FirestoreInstance.USERS)
            .document(idPair.parentUuid)
            .collection(secondKey)
            .document(idPair.uuid)
            .getDocument { (document, _) in
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

    func getPhoto(setImageTo imageView: UIImageView, with photoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if photoId.isEmpty {
            completion(.failure(FirebaseError.invalidUrl))
            return
        }

        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/cloudcardsmobile.appspot.com/o/\(photoId)?alt=media")
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            options: [
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success:
                imageView.image = imageView.image!.resized(toWidth: imageView.frame.width * 10)
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
