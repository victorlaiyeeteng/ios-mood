//
//  LoginView.swift
//  Mood Tracker
//
//  Created by Victor Lai on 8/12/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager()
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var showDetails = false

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)

            Button("Login") {
                authManager.login(email: email, password: password) { result in
                    switch result {
                    case .success:
                        showDetails = true
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .fullScreenCover(isPresented: $showDetails) {
            if let user = authManager.currentUser {
                UserDetailsView(user: user)
            }
        }
    }
}

//#Preview {
//    LoginView()
//}
