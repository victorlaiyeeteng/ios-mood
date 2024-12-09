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
    @State private var partnerUsername = ""
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
                    Text("Here's how you and \(partnerUsername) are feeling...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                
                List {
                    Section(header: Text(partnerUsername.isEmpty ? "user" : partnerUsername)) {
                        ForEach(viewModel.moods.filter { $0.uploader != currentUsername }) { mood in
                            HStack {
                                Text(mood.emoji)
                                    .font(.largeTitle)
                                VStack(alignment: .leading) {
                                    Text(mood.caption)
                                        .font(.body)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    if !isToday(mood.timestamp) {
                                        Text(formatDate(mood.timestamp))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(formatTime(mood.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                            }
                        }
                    }

                    Section(header: Text("you")) {
                        ForEach(viewModel.moods.filter { $0.uploader == currentUsername }) { mood in
                            HStack {
                                Text(mood.emoji)
                                    .font(.largeTitle)
                                VStack(alignment: .leading) {
                                    Text(mood.caption)
                                        .font(.body)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    if !isToday(mood.timestamp) {
                                        Text(formatDate(mood.timestamp))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(formatTime(mood.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                            }
                        }
                        .onDelete(perform: deleteMood)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
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
                                Button("Cancel") {
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
                        partnerUsername = user.partnerUsername
                    case .failure(let error):
                        print("Failed to fetch user details: \(error.localizedDescription)")
                    }
                }
            }
            viewModel.fetchMoods()
        }
    }
    
    private func deleteMood(at offsets: IndexSet) {
        for index in offsets {
            let mood = viewModel.moods.filter { $0.uploader == currentUsername }[index]
            viewModel.deleteMood(moodId: mood.id)
        }
    }
    
    func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        if calendar.isDateInToday(date) {
            return ""
        } else {
            formatter.dateFormat = "d MMM" // Format: Day/Month
            return formatter.string(from: date)
        }
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h.mm a" // Format: Time in 12-hour format
        return formatter.string(from: date)
    }
}

//#Preview {
//    MoodsView()
//}
