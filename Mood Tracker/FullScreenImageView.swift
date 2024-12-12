//
//  FullScreenImageView.swift
//  Mood Tracker
//
//  Created by Victor Lai on 10/12/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct FullScreenImageView: View {
    let mediaUrl: String
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel = ReactionsViewModel()
    let emoji: String

    var body: some View {
        NavigationView {
            AsyncImage(url: URL(string: mediaUrl)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                ProgressView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}


