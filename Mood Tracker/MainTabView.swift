//
//  MainTabView.swift
//  Mood Tracker
//
//  Created by Victor Lai on 9/12/24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MoodsView()
                .tabItem {
                    Label("Moods", systemImage: "face.smiling")
                }
            ReactionsView()
                .tabItem {
                    Label("Reactions", systemImage: "hand.thumbsup.fill")
                }
        }
    }
}

//#Preview {
//    MainTabView()
//}
