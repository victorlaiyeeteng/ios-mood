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
    @State private var showAddMood = false
    @State private var newCaption = ""
    @State private var selectedEmoji = "😊"
    
    let emojis = ["😊", "😔", "😡", "😴", "😂"]
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome, \(Auth.auth().currentUser?.email ?? "User")")
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
                    VStack(spacing: 16) {
                        Text("How are you?")
                            .font(.headline)
                        Picker("Emoji", selection: $selectedEmoji) {
                            ForEach(emojis, id: \.self) { emoji in
                                Text(emoji).tag(emoji)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        TextField("Caption", text: $newCaption)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                        
                        Button("Upload") {
                            viewModel.uploadMood(emoji: selectedEmoji, caption: newCaption)
                            showAddMood = false
                            newCaption = ""
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Moods")
        .onAppear {
            viewModel.fetchMoods()
        }
    }
}

//#Preview {
//    MoodsView()
//}
