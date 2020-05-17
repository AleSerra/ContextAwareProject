//
//  NotificationPublisher.swift
//  BoloFence
//
//  Created by Luca D'Ambrosio on 09/05/2020.
//  Copyright © 2020 Luca D'Ambrosio. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationPublisher: NSObject {
    
    func sendNotification(title: String, body: String, badge:Int?, delayInterval: Int?) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        
        var delayTimeTrigger: UNTimeIntervalNotificationTrigger?
        
        if let delayInterval = delayInterval {
            delayTimeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(delayInterval), repeats: false)
        }
        
        if let badge = badge {
            var currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
            currentBadgeCount += 1
            notificationContent.badge = NSNumber(integerLiteral: currentBadgeCount)
            
        }
        notificationContent.sound = UNNotificationSound.default
        UNUserNotificationCenter.current().delegate = self
        
        let request = UNNotificationRequest(identifier: "TestLocalNotification", content: notificationContent, trigger: delayTimeTrigger)
        
        UNUserNotificationCenter.current().add(request){ error in
            if let error = error {
                print("Error notification:", error)
            }
        }
    }
}

extension NotificationPublisher: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("The notification is about to presented")
        completionHandler([.badge, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        
        switch identifier {
        
        case UNNotificationDismissActionIdentifier:
            print("Notification was dismissed")
            completionHandler()
  
        case UNNotificationDefaultActionIdentifier:
            print("The user opened the app from the notification")
            completionHandler()
        
        default:
            print("Default notification")
            completionHandler()
        }
    }
}
