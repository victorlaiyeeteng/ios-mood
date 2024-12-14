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
    
    private func scheduleReminderNotification() {
        let singaporeTimeZone = TimeZone(identifier: "Asia/Singapore")!
        let messageTimes: [(hour: Int, minute: Int)] = [
            (8, 0),
            (12, 0),
            (15, 0),
            (18, 0),
            (21, 0),
            (0, 0)
        ]
        
        for (index, message) in NotifMessages.messages.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "🤍🤍"
            content.body = message
            content.sound = .default
            var dateComponents = DateComponents()
            dateComponents.timeZone = singaporeTimeZone
            dateComponents.hour = messageTimes[index].hour
            dateComponents.minute = messageTimes[index].minute
            dateComponents.second = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "daily-message-\(index)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling daily notification \(index + 1): \(error.localizedDescription)")
                } else {
                    print("Daily notification \(index + 1) scheduled for \(messageTimes[index].hour):00")
                }
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
