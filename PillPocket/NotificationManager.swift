//
//  NotificationManager.swift
//  PillPocket
//
//  Created by ramya nomula on 1/19/24.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // Handle notifications while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // print("userNotificationCenter(_:willPresent:withCompletionHandler: got called")
        completionHandler([.banner, .sound])
    }

    // Other methods like scheduleNotification, requestPermission, etc.
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification response here (e.g., when user taps the notification)
        completionHandler()
    }

}



