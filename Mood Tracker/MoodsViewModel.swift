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
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    return Mood(id: doc.documentID, emoji: emoji, caption: caption, uploader: uploader, timestamp: timestamp.dateValue())
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
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    return Mood(id: doc.documentID, emoji: emoji, caption: caption, uploader: uploader, timestamp: timestamp.dateValue())
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
                          let uploader = data["uploader"] as? String else {
                        return nil
                    }
                    return Mood(id: doc.documentID, emoji: emoji, caption: caption, uploader: uploader, timestamp: timestamp.dateValue())
                } ?? []
            }
    }
    
    func uploadMood(emoji: String, caption: String) {
        guard let currentUser = auth.currentUser else { return }
        
        let userId = currentUser.uid
        AuthManager().fetchUserDetails(userId: userId) { result in
            switch result {
            case.success(let user):
                let newMood: [String: Any] = [
                    "emoji": emoji,
                    "caption": caption,
                    "timestamp": Timestamp(),
                    "uploader": user.username
                ]
                self.db.collection("moods").addDocument(data: newMood) { error in
                    if let error = error {
                        print("Error uploading mood: \(error.localizedDescription)")
                    } else {
                        self.fetchMoods()
                    }
                }
                
            case.failure(let error):
                print("Error fetching user details: \(error.localizedDescription)")
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
