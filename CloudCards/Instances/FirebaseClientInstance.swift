class FirebaseClientInstance {
    private static var firebaseClient: FirebaseClientImpl?

    static func getInstance() -> FirebaseClientImpl {

        if firebaseClient == nil {
            firebaseClient = FirebaseClientImpl()
        }

        return firebaseClient!
    }
}
