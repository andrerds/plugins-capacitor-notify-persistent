//
//  SharedUNUserNotificationCenterDelegate.swift
//  CapacitorNotifyPersistent
//
//  Created by André de Souza on 28/06/24.
//

import Foundation
import UserNotifications

public class SharedUNUserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {

    public static let shared = SharedUNUserNotificationCenterDelegate()
    private var delegates: [UNUserNotificationCenterDelegate] = []

    private override init() {}

    func addDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        delegates.append(delegate)
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        for delegate in delegates {
            delegate.userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)
        }
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        for delegate in delegates {
            delegate.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
        }
    }
}
