//
//  EmojiReactionsView.swift
//  Mood Tracker
//
//  Created by Victor Lai on 10/12/24.
//

import SwiftUI
import PhotosUI

struct EmojiReactionsView: View {
    let emoji: String
    @ObservedObject var viewModel: ReactionsViewModel
    @State private var fullScreenImage: FullScreenImage? = nil
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var mediaUrl: URL? = nil
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        VStack {
            if let reactions = viewModel.reactionsByEmoji[emoji], reactions.contains(where: { !$0.mediaUrls.isEmpty }) {
                ScrollView {
                    LazyVGrid(columns: gridItemLayout, spacing: 10) {
                        ForEach(reactions.flatMap { $0.mediaUrls }, id: \.self) { mediaUrl in
                            Button(action: {
                                fullScreenImage = FullScreenImage(url: mediaUrl)
                            }) {
                                AsyncImage(url: URL(string: mediaUrl)) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                    .padding()
                }
            } else {
                Text("No reactions yet")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationTitle("\(emoji)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingImagePicker.toggle()
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
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
                viewModel.uploadReaction(emoji: emoji, mediaUrl: mediaUrl)
            }
        }
        .fullScreenCover(item: $fullScreenImage) { fullScreenImage in
            FullScreenImageView(mediaUrl: fullScreenImage.url)
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


struct FullScreenImage: Identifiable {
    var id: String { url }  // Make the URL unique by using it as the ID
    let url: String
}
