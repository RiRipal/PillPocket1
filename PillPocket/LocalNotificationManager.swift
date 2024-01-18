//
//  NotificationManager.swift
//  PillPocket
//
//  Created by ramya nomula on 1/19/24.
//

import Foundation
import UserNotifications

class LocalNotificationManager {

    // Request permission to send notifications
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                // print("Notification permission granted.")
            } else if let error = error {
                // print("Notification permission error: \(error)")
            }
        }
        
        
    }
    
    
    
    
    
    // Schedule a test notification for 14:50
        static func scheduleTestNotification() {
            let content = UNMutableNotificationContent()
            content.title = "Test Notification"
            content.body = "This is a test notification scheduled for 14:50."
            content.sound = .default
            content.categoryIdentifier = "MEDICATION_CATEGORY"
            // print("scheduleTestNotification got called")
            var dateComponents = DateComponents()
            dateComponents.hour = 21
            dateComponents.minute = 03

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    // print("Error scheduling test notification: \(error)")
                } else {
                    // print("Test notification scheduled for 9:03 PM")
                }
            }
        }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    static func registerNotificationCategory() {
          let takenAction = UNNotificationAction(identifier: "TAKEN_ACTION", title: "Ok", options: [])
          let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION", title: "Snooze", options: [])

          let category = UNNotificationCategory(identifier: "MEDICATION_CATEGORY", actions: [takenAction, snoozeAction], intentIdentifiers: [], options: [])
          
          UNUserNotificationCenter.current().setNotificationCategories([category])
      }

    
    static func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
          UNUserNotificationCenter.current().getNotificationSettings { settings in
              DispatchQueue.main.async {
                  if settings.authorizationStatus == .authorized {
                      completion(true)
                  } else {
                      completion(false)
                  }
              }
          }
      }
    
    
    
    /*
    
    
    // Schedule a local notification
        static func scheduleNotification(reminder: ReminderHome) {
            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = "It's time to take your medication: \(reminder.r_S_medicine)"
            content.sound = .default
            content.categoryIdentifier = "MEDICATION_CATEGORY"

            // Assuming `r_D_datetobetaken` and `r_T_rem1` are strings in the format "yyyy-MM-dd" and "HH:mm"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"

            // print("scheduleNotification is called")
            
            if let date = dateFormatter.date(from: reminder.r_D_datetobetaken),
               let time = timeFormatter.date(from: reminder.r_T_rem1),
               let combinedDateTime = combineDateWithTime(date: date, time: time) {
               
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: combinedDateTime)
                
                // print("Combined Date Time: \(combinedDateTime)")
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        // print("Error scheduling notification: \(error)")
                    }
                }
            } else {
                // print("Error: Invalid date/time format")
            }
        }

        static func combineDateWithTime(date: Date, time: Date) -> Date? {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

            return calendar.date(from: DateComponents(
                year: dateComponents.year,
                month: dateComponents.month,
                day: dateComponents.day,
                hour: timeComponents.hour,
                minute: timeComponents.minute
            ))
        }

        */
    
    static func removeAllScheduledNotifications() {
           UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
       }
    
    
    
    
    /*fox
    

    static func scheduleNotification(reminder: ReminderHome) {
        // print("scheduleNotification got called")
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "It's time to take your medication: \(reminder.r_S_medicine)"
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_CATEGORY"

        // Combine date and time into one string
        let combinedDateTimeString = "\(reminder.r_D_datetobetaken) \(reminder.r_T_rem1)"
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateTimeFormatter.timeZone = TimeZone.current // Set to the current timezone

        // print("combinedDateString", combinedDateTimeString)

        if let combinedDateTime = dateTimeFormatter.date(from: combinedDateTimeString) {
            // Print the combined date and time in the user's current timezone
            // print("Combined Date Time (User's Timezone): \(dateTimeFormatter.string(from: combinedDateTime))")

            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: combinedDateTime)

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    // print("Error scheduling notification: \(error)")
                }
            }
        } else {
            // print("Error: Invalid combined date/time format")
        }
    }

    fox */
    
    /*
  
    static func scheduleNotification(reminder: ReminderHome) {
        // print("scheduleNotification got called")
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "It's time to take your medication: \(reminder.r_S_medicine)"
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_CATEGORY"

        // Combine date and time into one string
        let combinedDateTimeString = "\(reminder.r_D_datetobetaken) \(reminder.r_T_rem1)"
        let dateTimeFormatter = DateFormatter()
        // Update the format to match the combined string
        dateTimeFormatter.dateFormat = "yyyy-MM-dd h:mm a" // Adjusted for 12-hour format and AM/PM
        dateTimeFormatter.timeZone = TimeZone.current // Ensure the timezone is set correctly

        // print("combinedDateString", combinedDateTimeString)

        if let combinedDateTime = dateTimeFormatter.date(from: combinedDateTimeString) {
            // print("Combined Date Time (User's Timezone): \(dateTimeFormatter.string(from: combinedDateTime))")

            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: combinedDateTime)

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    // print("Error scheduling notification: \(error)")
                }
            }
        } else {
            // print("Error: Invalid combined date/time format")
        }
    }
*/
/*
    static func scheduleNotification(reminder: ReminderHome) {
        // print("scheduleNotification got called")
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "It's time to take your medication: \(reminder.r_S_medicine)"
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_CATEGORY"

        // Combine date and time into one string
        let combinedDateTimeString = "\(reminder.r_D_datetobetaken) \(reminder.r_T_rem1)"
        let dateTimeFormatter = DateFormatter()
        // Update the format to match the combined string
        dateTimeFormatter.dateFormat = "yyyy-MM-dd h:mm a" // Adjusted for 12-hour format and AM/PM
        dateTimeFormatter.timeZone = TimeZone.current // Ensure the timezone is set correctly

        // print("combinedDateString", combinedDateTimeString)

        if let combinedDateTime = dateTimeFormatter.date(from: combinedDateTimeString) {
            // print("Combined Date Time (User's Timezone): \(dateTimeFormatter.string(from: combinedDateTime))")

            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: combinedDateTime)

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    // print("Error scheduling notification: \(error)")
                }
            }
        } else {
            // print("Error: Invalid combined date/time format")
        }
    }

    
    
   foxy1 */
    
    
    
   
    
    static func scheduleNotification(reminder: ReminderHome) {
        // print("scheduleNotification got called")
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "It's time to take your medication: \(reminder.r_S_medicine)"
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_CATEGORY"
        
        
        
        
        let time = reminder.r_I_dosageIter == "1" ? reminder.r_T_rem1 :
        reminder.r_I_dosageIter == "2" ? reminder.r_T_rem2 :
        reminder.r_I_dosageIter == "3" ? reminder.r_T_rem3 : reminder.r_T_rem4
        
        
        
        
        if time != "" {
            
            
            
            
            let combinedDateTimeString = "\(reminder.r_D_datetobetaken) \(time)"
            
            
            
            
            let dateTimeFormatter = DateFormatter()
            // Update the format to match the combined string
            dateTimeFormatter.dateFormat = "yyyy-MM-dd h:mm a" // Adjusted for 12-hour format and AM/PM
            dateTimeFormatter.timeZone = TimeZone.current // Ensure the timezone is set correctly
            
            // print("combinedDateString", combinedDateTimeString)
            
            if let combinedDateTime = dateTimeFormatter.date(from: combinedDateTimeString) {
                // print("Combined Date Time (User's Timezone): \(dateTimeFormatter.string(from: combinedDateTime))")
                
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: combinedDateTime)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        // print("Error scheduling notification: \(error)")
                    }
                }
            } else {
                // print("Error: Invalid combined date/time format")
            }
        }
        
        
    }
    
    

    
    
    
    
    
}
