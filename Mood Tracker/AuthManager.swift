//
//  AuthManager.swift
//  Mood Tracker
//
//  Created by Victor Lai on 8/12/24.
//

import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var currentUser: User?

    private let db = Firestore.firestore()
    private let usersCollection = "users"

    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid user ID."])))
                return
            }

            // Fetch user data from Firestore
            self?.db.collection(self!.usersCollection).document(uid).getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = snapshot?.data(),
                      let username = data["username"] as? String,
                      let email = data["email"] as? String,
                      let partnerUsername = data["partnerUsername"] as? String else {
                    completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Firestore data."])))
                    return
                }

                // Create a User object and update the state
                let user = User(id: uid, username: username, email: email, partnerUsername: partnerUsername)
                self?.currentUser = user
                completion(.success(()))
            }
        }
    }
    
    func fetchUserDetails(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection(usersCollection).document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let username = data["username"] as? String,
                  let email = data["email"] as? String,
                  let partnerUsername = data["partnerUsername"] as? String else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Firestore data."])))
                return
            }

            // Create a User object and return it
            let user = User(id: userId, username: username, email: email, partnerUsername: partnerUsername)
            completion(.success(user))
        }
    }
}
