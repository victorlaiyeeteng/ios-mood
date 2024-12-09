//
//  MoodsView.swift
//  Mood Tracker
//
//  Created by Victor Lai on 9/12/24.
//

import SwiftUI
import FirebaseAuth

struct MoodsView: View {
    @StateObject private var viewModel = MoodsViewModel()
    @State private var currentUsername = ""
    @State private var showAddMood = false
    @State private var newCaption = ""
    @State private var selectedEmoji = "😊"
    
    let emojis = ["😊", "😔", "😡", "😴", "😂"]
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome, \(currentUsername.isEmpty ? "User" : currentUsername)")
                        .font(.headline)
                    Text("Here are your moods and your partner's moods:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                List(viewModel.moods) { mood in
                    HStack {
                        Text(mood.emoji)
                            .font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text(mood.caption)
                                .font(.body)
                            Text(mood.uploader)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(mood.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: { showAddMood.toggle() }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Mood")
                    }
                    .font(.headline)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showAddMood) {
                    NavigationView {
                        VStack(spacing: 16) {
                            Text("How are you?")
                                .font(.headline)
                            Picker("Emoji", selection: $selectedEmoji) {
                                ForEach(emojis, id: \.self) { emoji in
                                    Text(emoji).tag(emoji)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            VStack(alignment: .leading) {
                                Text("Caption")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .autocapitalization(.none)
                                ResizableTextField(text: $newCaption)
                                    .frame(minHeight: 40)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 4)
                            }
                            .padding()
                            
                            Button("Share") {
                                viewModel.uploadMood(emoji: selectedEmoji, caption: newCaption)
                                showAddMood = false
                                newCaption = ""
                                selectedEmoji = "😊"
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Spacer()
                        }
                        .padding()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Back") {
                                    showAddMood = false
                                    newCaption = ""
                                    selectedEmoji = "😊"
                                }
                            }
                        }
                        .navigationTitle("Share Mood")
                    }
                }
            }
        }
        .navigationTitle("Moods")
        .onAppear {
            if let userId = Auth.auth().currentUser?.uid {
                AuthManager().fetchUserDetails(userId: userId) { result in
                    switch result {
                    case .success(let user):
                        currentUsername = user.username
                    case .failure(let error):
                        print("Failed to fetch user details: \(error.localizedDescription)")
                    }
                }
            }
            viewModel.fetchMoods()
        }
    }
}

//#Preview {
//    MoodsView()
//}
