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
    
    let emojis = ["😊", "😂", "😴", "😔", "😡"]
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome!")
                        .font(.title)
                    Text("Here's how you and \(partnerUsername) are feeling...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                
                List {
                    Section(header: Text(partnerUsername.isEmpty ? "partner" : partnerUsername)) {
                        ForEach(viewModel.partnerMoods) { mood in
                            MoodRow(mood: mood)
                        }
                        NavigationLink(destination: AllMoodsView(uploader: partnerUsername, viewModel: viewModel)) {
                            Text("View All")
                                .foregroundColor(.blue)
                        }
                    }

                    Section(header: Text("you")) {
                        ForEach(viewModel.userMoods) { mood in
                            MoodRow(mood: mood)
                        }
                        .onDelete(perform: deleteMood)
                        NavigationLink(destination: AllMoodsView(uploader: currentUsername, viewModel: viewModel)) {
                            Text("View All")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .refreshable {
                    await refreshMoods()
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
                            
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Share") {
                                    viewModel.uploadMood(emoji: selectedEmoji, caption: newCaption)
                                    showAddMood = false
                                    newCaption = ""
                                    selectedEmoji = "😊"
                                }
                                .foregroundColor(newCaption.isEmpty ? .gray : .blue)
                                .disabled(newCaption.isEmpty)
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
                        viewModel.fetchLatestMoods(for: currentUsername, limit: 3) { moods in
                            viewModel.userMoods = moods
                        }
                        viewModel.fetchLatestMoods(for: partnerUsername, limit: 3) { moods in
                            viewModel.partnerMoods = moods
                        }
                    case .failure(let error):
                        print("Failed to fetch user details: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func refreshMoods() async {
        if let userId = Auth.auth().currentUser?.uid {
            AuthManager().fetchUserDetails(userId: userId) { result in
                switch result {
                case .success(let user):
                    viewModel.fetchLatestMoods(for: user.username, limit: 3) { moods in
                        DispatchQueue.main.async {
                            viewModel.userMoods = moods
                        }
                    }
                    viewModel.fetchLatestMoods(for: user.partnerUsername, limit: 3) { moods in
                        DispatchQueue.main.async {
                            viewModel.partnerMoods = moods
                        }
                    }
                case .failure(let error):
                    print("Failed to fetch user details: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deleteMood(at offsets: IndexSet) {
        for index in offsets {
            let mood = viewModel.moods.filter { $0.uploader == currentUsername }[index]
            viewModel.deleteMood(moodId: mood.id)
        }
    }
}


struct MoodRow: View {
    let mood: Mood
    
    var body: some View {
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


struct AllMoodsView: View {
    let uploader: String
    @ObservedObject var viewModel: MoodsViewModel

    var body: some View {
        List(viewModel.moods) { mood in
            MoodRow(mood: mood)
        }
        .listStyle(PlainListStyle())
        .navigationTitle("\(uploader)'s moods")
        .onAppear {
            viewModel.fetchAllMoods(for: uploader) { moods in
                viewModel.moods = moods
            }
        }
        
    }
}
