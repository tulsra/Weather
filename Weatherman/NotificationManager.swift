import UIKit
import UserNotifications
import Combine

@MainActor
final class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var deviceToken: String?  // Hex string
    @Published private(set) var lastRegistrationError: Error?

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        refreshAuthorizationStatus()
    }

    // MARK: - Public API

    /// Ask for permission and, if granted, register with APNs.
    func requestAuthorizationAndRegister() {
        Task {
            do {
                let granted = try await requestAuthorization()
                if granted {
                    await registerForRemoteNotifications()
                }
            } catch {
                self.lastRegistrationError = error
            }
            await refreshAuthorizationStatus()
        }
    }

    /// Register for APNs if you already have permission
    func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    /// Open Settings if permission is denied
    func openAppNotificationSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Internal hooks from AppDelegate

    func handleDidRegister(deviceToken: Data) {
        let hex = deviceToken.map { String(format: "%02x", $0) }.joined()
        self.deviceToken = hex
        self.lastRegistrationError = nil
        // TODO: send `hex` to your server here
        print("APNs token: \(hex)")
    }

    func handleDidFailToRegister(error: Error) {
        self.lastRegistrationError = error
        print("Failed to register for remote notifications: \(error)")
    }

    // MARK: - Helpers

    private func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        )
    }

    private func refreshAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate (optional handling)

extension NotificationManager: UNUserNotificationCenterDelegate {
    // Called when a notification is delivered while the app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Decide how to show notifications in foreground
        return [.banner, .sound, .badge]
    }

    // Called when user taps a notification
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // Handle deep links / routing if needed
    }
}

==============================================================================
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Optional: nothing needed here for APNs specifically
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            NotificationManager.shared.handleDidRegister(deviceToken: deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task { @MainActor in
            NotificationManager.shared.handleDidFailToRegister(error: error)
        }
    }
}

==============================================================================
import SwiftUI

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
        }
    }
}


==============================================================================
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var notifications: NotificationManager

    var body: some View {
        VStack(spacing: 12) {
            Text("Authorization: \(String(describing: notifications.authorizationStatus))")

            if let token = notifications.deviceToken {
                Text("APNs Token:")
                ScrollView { Text(token).textSelection(.enabled).font(.footnote).monospaced() }
                    .frame(maxHeight: 120)
            } else if let err = notifications.lastRegistrationError {
                Text("Registration error: \(err.localizedDescription)")
                    .foregroundColor(.red)
            }

            Button("Enable Push & Register") {
                notifications.requestAuthorizationAndRegister()
            }

            Button("Open Notification Settings") {
                notifications.openAppNotificationSettings()
            }
        }
        .padding()
        .onAppear {
            // If already authorized, you can register immediately:
            if notifications.authorizationStatus == .authorized ||
               notifications.authorizationStatus == .provisional ||
               notifications.authorizationStatus == .ephemeral {
                Task { await notifications.registerForRemoteNotifications() }
            }
        }
    }
}

