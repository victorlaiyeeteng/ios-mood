//
//  ReactionsView.swift
//  Mood Tracker
//
//  Created by Victor Lai on 9/12/24.
//

import SwiftUI
import PhotosUI

struct ReactionsView: View {
    @StateObject private var viewModel = ReactionsViewModel()
    @State private var selectedEmoji = "😊"
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var mediaUrl: URL? = nil
    
    let emojis = ["😊", "😂", "😴", "😔", "😡"]

    
    var body: some View {
        NavigationView {
            VStack {
                List(emojis, id: \.self) { emoji in
                    HStack {
                        Text(emoji)
                            .font(.largeTitle)
                    }
                    if let reactions = viewModel.reactionsByEmoji[emoji], !reactions.isEmpty {
                        ForEach(reactions, id: \.id) { reaction in
                            ForEach(reaction.mediaUrls, id: \.self) { mediaUrl in
                                AsyncImage(url: URL(string: mediaUrl)) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    } else {
                        Text("No reactions yet")
                    }
                    
                    Button(action: {
                        selectedEmoji = emoji
                        showingImagePicker.toggle()
                    }) {
                        Text("Add Reaction")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("My Reactions")
        }
        .onAppear {
            viewModel.fetchReactions()
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem, matching: .any(of: [.images, .videos]))
        .onChange(of: selectedItem) { _, newItem in
            guard let selectedItem = newItem else { return }
            Task {
                if let data = try? await selectedItem.loadTransferable(type: Data.self),
                   let tempFileURL = saveDataToTempFile(data) {
                    mediaUrl = tempFileURL
                }
            }
        }
        .onChange(of: mediaUrl) { _, newValue in
            if let mediaUrl = newValue {
                viewModel.uploadReaction(emoji: selectedEmoji, mediaUrl: mediaUrl)
            }
        }
    }
    
    private func saveDataToTempFile(_ data: Data) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString)
        
        do {
            try data.write(to: tempFileURL)
            return tempFileURL
        } catch {
            print("Error saving data to temp file: \(error.localizedDescription)")
            return nil
        }
    }
}



