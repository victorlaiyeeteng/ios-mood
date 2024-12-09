//
//  Mood.swift
//  Mood Tracker
//
//  Created by Victor Lai on 9/12/24.
//

import Foundation

struct Mood: Identifiable {
    let id: String
    let emoji: String
    let caption: String
    let uploader: String
    let timestamp: Date
}
