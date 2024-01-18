//
//  RemindersManager.swift
//  PillPocket
//
//  Created by ramya nomula on 2/6/24.
//

import Foundation
import Foundation
import SwiftUI

class RemindersManager: ObservableObject {
    static let shared = RemindersManager() // Singleton for global access

    // Example function to update reminders and notifications
    func updateRemindersAndNotifications() {
         //Clear existing notifications
        LocalNotificationManager.removeAllScheduledNotifications()
        
        // Fetch or update reminders
        // This step might need adjustment based on how you fetch or store your reminders
   
        
        // Schedule new notifications for active reminders
        scheduleTodayReminders()
    }
    
    // Function to schedule reminders
 func scheduleTodayReminders() {
        do {
            // print("scheduleTodayReminders got called")
            let reminders = try DatabaseManager.shared.fetchRemindersHome()
            reminders.forEach { reminder in
                LocalNotificationManager.scheduleNotification(reminder: reminder)
            }
        } catch {
            // print("Error: \(error)")
        }
    }
    func printScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let fireDate = trigger.nextTriggerDate() {
                    // print("ID: \(request.identifier)")
                    // print("Title: \(request.content.title)")
                    // print("Body: \(request.content.body)")
                    // print("Scheduled to fire at: \(fireDate)")
                } else {
                  //   print("ID: \(request.identifier)")
                    // print("Title: \(request.content.title)")
                    // print("Body: \(request.content.body)")
                    // print("Trigger: \(String(describing: request.trigger))")
                }
            }
            
            if requests.isEmpty {
                // print("No scheduled notifications.")
            }
        }
    }

    
}
