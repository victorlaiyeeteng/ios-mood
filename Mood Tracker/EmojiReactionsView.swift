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
    @State private var isEditing = false
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        VStack {
            if let reactions = viewModel.reactionsByEmoji[emoji], reactions.contains(where: { !$0.mediaUrls.isEmpty }) {
                ScrollView {
                    LazyVGrid(columns: gridItemLayout, spacing: 10) {
                        ForEach(reactions.flatMap { $0.mediaUrls }, id: \.self) { mediaUrl in
                            ZStack {
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
                                .buttonStyle(PlainButtonStyle())
                                if isEditing {
                                    Button(action: {
                                        showDeleteConfirmation(for: mediaUrl)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Circle().fill(Color.white))
                                            .frame(width: 24, height: 24)
                                    }
                                    .offset(x: 50, y: -50)
                                }
                            }
                            .frame(width: 120, height: 120)
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
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
            FullScreenImageView(mediaUrl: fullScreenImage.url, emoji: emoji)
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
    
    private func showDeleteConfirmation(for mediaUrl: String) {
        let alert = UIAlertController(
            title: "Delete Image",
            message: "Are you sure you want to delete this image?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            viewModel.deleteImage(for: emoji, mediaUrl: mediaUrl) { result in
                switch result {
                case .success:
                    print("Image successfully deleted")
                case .failure(let error) :
                    print("Failed to delete image: \(error.localizedDescription)")
                }
            }
        })

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let controller = window.rootViewController {
            controller.present(alert, animated: true, completion: nil)
        }
    }
}


struct FullScreenImage: Identifiable {
    var id: String { url }  // Make the URL unique by using it as the ID
    let url: String
}
