//
//  UserDetailsView.swift
//  Mood Tracker
//
//  Created by Victor Lai on 8/12/24.
//

import SwiftUI

struct UserDetailsView: View {
    let user: User

        var body: some View {
            VStack(spacing: 16) {
                Text("Welcome, \(user.username)!")
                    .font(.title)
                    .padding()

                Text("Email: \(user.email)")
                Text("Partner's Username: \(user.partnerUsername)")

                Spacer()
            }
            .padding()
        }
}

//#Preview {
//    UserDetailsView()
//}
