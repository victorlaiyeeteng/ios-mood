//
//  ReactionsViewModel.swift
//  Mood Tracker
//
//  Created by Victor Lai on 10/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class ReactionsViewModel: ObservableObject {
    @Published var reactionsByEmoji: [String: [Reaction]] = [:]  // Keyed by emoji
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let auth = Auth.auth()
    
    // Fetch reactions for each emoji (limit to 3)
    func fetchReactions() {
        guard let userId = auth.currentUser?.uid else { return }
        
        db.collection("reactions")
            .document(userId)
            .getDocument{ snapshot, error in
                if let error = error {
                    print("Error fetching reactions: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                
                var reactionsDict: [String: [Reaction]] = [:]
                for (emoji, mediaUrls) in data {
                    guard let mediaUrls = mediaUrls as? [String] else { continue }
                    let reaction = Reaction(id: emoji, emoji: emoji, mediaUrls: mediaUrls)
                    reactionsDict[emoji] = [reaction]
                }
                self.reactionsByEmoji = reactionsDict
            }
    }
    
    
    // Upload a new reaction (photo/video)
    func uploadReaction(emoji: String, mediaUrl: URL) {
        guard let userId = auth.currentUser?.uid else { return }
        
        let storageRef = storage.reference().child("reactions/\(userId)/\(emoji)/\(UUID().uuidString).jpg")
        storageRef.putFile(from: mediaUrl, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading reaction: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    return
                }
                guard let url = url else { return }
                let userRef = self.db.collection("reactions").document(userId)
                userRef.updateData([
                    emoji: FieldValue.arrayUnion([url.absoluteString])
                ]) { error in
                    if let error = error {
                        print("Error saving reaction to firestore: \(error.localizedDescription)")
                    } else {
                        self.fetchReactions()
                    }
                }
            }
        }
    }
    
    // Delete a reaction
    func deleteReaction(reactionId: String) {
        return
    }
}
