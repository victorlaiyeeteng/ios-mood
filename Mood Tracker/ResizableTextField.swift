//
//  ResizableTextField.swift
//  Mood Tracker
//
//  Created by Victor Lai on 9/12/24.
//

import SwiftUI

struct ResizableTextField: View {
    @Binding var text: String
    @State private var textHeight: CGFloat = 80 // Initial height

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder text
            if text.isEmpty {
                Text("Enter your caption...")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            
            // TextEditor for multiline input
            TextEditor(text: $text)
                .frame(height: textHeight)
                .padding(4)
                .onChange(of: text) { adjustHeight() } // Adjust height dynamically
        }
        .onAppear(perform: adjustHeight) // Adjust height on appear
    }
    
    private func adjustHeight() {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let size = CGSize(width: UIScreen.main.bounds.width - 64, height: .infinity) // Adjust width
        let attributes = [NSAttributedString.Key.font: font]
        let boundingBox = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        textHeight = max(100, boundingBox.height + 16) // Minimum height is 40
    }
}
