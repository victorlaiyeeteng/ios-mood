//
//  MoodsViewModel.swift
//  Mood Tracker
//
//  Created by Victor Lai on 9/12/24.
//

import FirebaseFirestore
import FirebaseAuth


class MoodsViewModel: ObservableObject {
    @Published var moods: [Mood] = []
    @Published var userMoods: [Mood] = []
    @Published var partnerMoods: [Mood] = []
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    func fetchLatestMoods(for uploader: String, limit: Int, completion: @escaping ([Mood]) -> Void) {
        db.collection("moods")
            .whereField("uploader", isEqualTo: uploader)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching moods: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let moods = snapshot?.documents.compactMap { doc -> Mood? in
                    let data = doc.data()
                    guard let emoji = data["emoji"] as? String,
                            let caption = data["caption"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp,
                          let reactionMediaUrl = data["reactionMediaUrl"] as? String else {
                        return nil
                    }
                    return Mood(id: doc.documentID, emoji: emoji, caption: caption, uploader: uploader, timestamp: timestamp.dateValue(), reactionMediaUrl: reactionMediaUrl)
                } ?? []
                completion(moods)
            }
        
    }
    
    func fetchAllMoods(for uploader: String, completion: @escaping ([Mood]) -> Void) {
        db.collection("moods")
            .whereField("uploader", isEqualTo: uploader)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching moods: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let moods = snapshot?.documents.compactMap { doc -> Mood? in
                    let data = doc.data()
                    guard let emoji = data["emoji"] as? String,
                            let caption = data["caption"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp,
                        let reactionMediaUrl = data["reactionMediaUrl"] as? String else {
                        return nil
                    }
                    return Mood(id: doc.documentID, emoji: emoji, caption: caption, uploader: uploader, timestamp: timestamp.dateValue(), reactionMediaUrl: reactionMediaUrl)
                } ?? []
                completion(moods)
            }
        
    }
    
    func fetchMoods() {
        db.collection("moods")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching moods: \(error.localizedDescription)")
                    return
                }
                
                self.moods = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    guard let emoji = data["emoji"] as? String,
                            let caption = data["caption"] as? String,
                            let timestamp = data["timestamp"] as? Timestamp,
                            let uploader = data["uploader"] as? String,
                            let reactionMediaUrl = data["reactionMediaUrl"] as? String else {
                        return nil
                    }
                    return Mood(id: doc.documentID, emoji: emoji, caption: caption, uploader: uploader, timestamp: timestamp.dateValue(), reactionMediaUrl: reactionMediaUrl)
                } ?? []
            }
    }
    
    func uploadMood(emoji: String, caption: String) {
        guard let currentUser = auth.currentUser else { return }
        
        let userId = currentUser.uid
        AuthManager().fetchUserDetails(userId: userId) { result in
            switch result {
            case.success(let user):
                let partnerUsername = user.partnerUsername
                
                self.fetchPartnerReactions(partnerUsername: partnerUsername, emoji: emoji) { reactionUrls in
                    let randomReactionUrl = reactionUrls.randomElement() ?? "https://firebasestorage.googleapis.com/v0/b/mood-tracker-d7fc3.firebasestorage.app/o/reactions%2Fcoming-soon.jpg?alt=media&token=8be0eadc-a4c2-494d-b6b4-19683bf0f651"
                    let newMood: [String: Any] = [
                        "emoji": emoji,
                        "caption": caption,
                        "timestamp": Timestamp(),
                        "uploader": user.username,
                        "reactionMediaUrl": randomReactionUrl
                    ]
                    self.db.collection("moods").addDocument(data: newMood) { error in
                        if let error = error {
                            print("Error uploading mood: \(error.localizedDescription)")
                        } else {
                            self.fetchLatestMoods(for: user.username, limit: 3) { moods in
                                DispatchQueue.main.async {
                                    self.userMoods = moods
                                }
                            }
                        }
                    }
                }
            case.failure(let error):
                print("Error fetching user details: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchPartnerReactions(partnerUsername: String, emoji: String, completion: @escaping ([String]) -> Void) {
        db.collection("users").whereField("username", isEqualTo: partnerUsername)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching partner's userId: \(error.localizedDescription)")
                    completion([])
                    return
                }
                guard let documents = snapshot?.documents, let document = documents.first else {
                    print("No user found with username \(partnerUsername)")
                    completion([])
                    return
                }
                let partnerUserId = document.documentID
                
                print(partnerUserId)
                
                self.db.collection("reactions").document(partnerUserId).getDocument { snapshot, error in
                    if let error = error {
                        print("Error fetching partner reactions: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    if let data = snapshot?.data(),
                       let emojiReactions = data[emoji] as? [String] {
                        completion(emojiReactions)
                    } else {
                        completion([])
                    }
                }
            }
    }
    
    func deleteMood(moodId: String) {
        db.collection("moods").document(moodId).delete { error in
            if let error = error {
                print("Error deleting mood: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.moods.removeAll {$0.id == moodId }
            }
        }
    }
}
