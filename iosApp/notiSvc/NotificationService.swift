//
//  NotificationService.swift
//  notiSvc
//
//  Created by Hoa Tran on 2/5/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import UserNotifications

class NotiState: ObservableObject {
    static let shared = NotiState()
    @Published var selectedGroupId : String?
    @Published var isNotified : Bool?
    
    func tapOnNotification() -> Bool {
        if (isNotified == true) {
            isNotified = false
            return true
        }
        return false
    }
}

class NotificationService: UNNotificationServiceExtension {
    
    static var selectedGroupId: String? = nil

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            let jsonString = bestAttemptContent.body
            let jsonData = jsonString.data(using: .utf8)!
            let notification = try! JSONDecoder().decode(NotificationDTO.self, from: jsonData)
            if (notification.action == "Message") {
                let data = notification.data
                let message = data.message
                bestAttemptContent.title = data.group.name ?? data.person.name ?? " "
                if (message.text != nil) {
                    bestAttemptContent.body = message.text!
                }
                if (message.attachment != nil) {
                    bestAttemptContent.body = "Send an attachment"
                }
                NotiState.shared.selectedGroupId = data.group.id
                let userDf = UserDefaults(suiteName: "group.ailaai.pushnotifications")
//                UserDefaults.standard.setValue("Hello", forKey: "Tmp1")
                userDf!.set(data.group.id, forKey: "notificationGroupId")
                userDf!.set(data.person.id, forKey: "notificationSenderId")
                userDf!.synchronize()
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
