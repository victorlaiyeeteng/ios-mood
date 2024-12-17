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
        VStack {
            Spacer()
            
            VStack(spacing: 8) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Login and start connecting more closely with your partner!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)
            
            VStack(spacing: 0) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedCorner(radius: 10, corners: [.topLeft, .topRight]))
                    .overlay(
                        RoundedCorner(radius: 10, corners: [.topLeft, .topRight])
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedCorner(radius: 10, corners: [.bottomLeft, .bottomRight]))
                    .overlay(
                        RoundedCorner(radius: 10, corners: [.bottomLeft, .bottomRight])
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .autocapitalization(.none)
            }
            .frame(maxWidth: 300)
            .padding(.bottom, 16)
            
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
            .frame(maxWidth: 270)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 8)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .frame(maxWidth: 300)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .fullScreenCover(isPresented: $showDetails) {
            if let user = authManager.currentUser {
                UserDetailsView(user: user)
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//#Preview {
//    LoginView()
//}
