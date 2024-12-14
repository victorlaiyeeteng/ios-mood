//
//  Mood_TrackerApp.swift
//  Mood Tracker
//
//  Created by Victor Lai on 6/12/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOption: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        requestNotificationPermission()
        scheduleReminderNotification()
        return true
    }
    
    let reminderMessages = [
        "Take a moment to relax and enjoy your day! Love, Victor.",
        "Remember to drink some water and stretch. Nagged by your baby with love!",
        "You're doing so great! Keep it up! Muacks!",
        "It's a good time to check in! Hope you're doing well hehe!",
        "Your baby misses you! Want to update him how you're feeling?"
    ]
    
    private func scheduleReminderNotification() {
        let randomIndex = Int.random(in: 0..<reminderMessages.count)
        let message = reminderMessages[randomIndex]
        let content = UNMutableNotificationContent()
        content.title = "🤍🤍"
        content.body = message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 14400, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func requestNotificationPermission() {
       UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
           if granted {
               print("Notification permission granted.")
           } else {
               print("Notification permission denied.")
           }
       }
   }
}

@main
struct Mood_TrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authManager = AuthManager()
    @State private var isUserLoggedIn = false
    @State private var isLoading = true
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
            Group {
                if isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                } else {
                    if isUserLoggedIn {
                        MainTabView()
                    } else {
                        LoginView()
                    }
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
                                            isLoading = false
                                        }
                                    } else {
                                        isUserLoggedIn = false
                                        isLoading = false
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
