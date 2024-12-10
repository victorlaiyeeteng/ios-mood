//
//  ReactionsView.swift
//  Mood Tracker
//
//  Created by Victor Lai on 9/12/24.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct ReactionsView: View {
    @StateObject private var viewModel = ReactionsViewModel()
    @State private var selectedEmoji = "😊"
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var mediaUrl: URL? = nil
    @State private var partnerUsername: String = ""
    
    let emojis = ["😊", "😂", "😴", "😔", "😡"]
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(emojis, id: \.self) { emoji in
                        NavigationLink(destination: EmojiReactionsView(emoji: emoji, viewModel: viewModel)) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(emoji)
                                        .font(.largeTitle)
                                    Spacer()
                                   
                                }
                                if let reactions = viewModel.reactionsByEmoji[emoji], reactions.contains(where: { !$0.mediaUrls.isEmpty }) {
                                    HStack {
                                        LazyVGrid(columns: gridItemLayout, spacing: 5) {
                                            ForEach(reactions.flatMap { $0.mediaUrls }.prefix(3), id: \.self) { mediaUrl in
                                                AsyncImage(url: URL(string: mediaUrl)) { image in
                                                    image.resizable()
                                                        .scaledToFill()
                                                        .frame(width: 90, height: 90)
                                                        .clipped()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            }
                                        }
                                        Spacer()
                                    }
                                } else {
                                    Text("No reactions yet")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("My Reactions")
        }
        .onAppear {
            fetchPartnerUsername()
            viewModel.fetchReactions()
        }
    }
    
    private func fetchPartnerUsername() {
        if let userId = Auth.auth().currentUser?.uid {
            AuthManager().fetchUserDetails(userId: userId) { result in
                switch result {
                case .success(let user):
                    self.partnerUsername = user.partnerUsername
                case .failure(let error):
                    print("Failed to fetch user details: \(error.localizedDescription)")
                }
            }
        }
    }
}



