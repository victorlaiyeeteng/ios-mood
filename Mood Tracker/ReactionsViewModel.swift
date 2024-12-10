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
        return
    }
    
    
    // Upload a new reaction (photo/video)
    func uploadReaction(emoji: String, mediaUrl: URL) {
        return
    }
    
    // Delete a reaction
    func deleteReaction(reactionId: String) {
        return
    }
}
