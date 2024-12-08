//
//  Mood_TrackerApp.swift
//  Mood Tracker
//
//  Created by Victor Lai on 6/12/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOption: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
        return true
    }
}

@main
struct Mood_TrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authManager = AuthManager()
    @State private var isUserLoggedIn = false
    @State private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        FirebaseApp.configure()
        print("Firebase App successfully configured.")
        if Auth.auth().currentUser != nil {
            isUserLoggedIn = true
        }
    }
    
    var body: some Scene {
        WindowGroup {
            VStack {
                if isUserLoggedIn {
                    if let user = authManager.currentUser {
                        UserDetailsView(user: user)
                    }
                } else {
                    LoginView()
                }
            }
            .onAppear {
                authStateListenerHandle = Auth.auth().addStateDidChangeListener { _, user in
                                    if let user = user {
                                        authManager.fetchUserDetails(userId: user.uid) { result in
                                            switch result {
                                            case .success(let currentUser):
                                                authManager.currentUser = currentUser
                                                isUserLoggedIn = true
                                            case .failure:
                                                isUserLoggedIn = false
                                            }
                                        }
                                    } else {
                                        isUserLoggedIn = false
                                    }
                                }
            }
            .onDisappear {
                            if let handle = authStateListenerHandle {
                                Auth.auth().removeStateDidChangeListener(handle)
                            }
                        }
        }
    }
}
