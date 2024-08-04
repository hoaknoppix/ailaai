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
        if let userDf = UserDefaults(suiteName: "group.ailaai.pushnotifications") {
            if let isTerminated = userDf.object(forKey: "isTerminated") as? Bool {
                if (isTerminated) {
                    return
                }
            }
            self.contentHandler = contentHandler
            bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
            if let bestAttemptContent = bestAttemptContent {
                // Modify the notification content here...
                let jsonString = bestAttemptContent.body
                print(jsonString)
                let jsonData = jsonString.data(using: .utf8)!
                let notification = try! JSONDecoder().decode(NotificationDTO.self, from: jsonData)
                userDf.set(notification.action, forKey: "notificationAction")
                if (notification.action == "Message") {
                    let data = notification.data
                    let message = data.message
                    bestAttemptContent.title = data.group.name ?? data.person.name ?? " "
                    if (message!.text != nil) {
                        bestAttemptContent.body = message!.text!
                    }
                    if (message!.attachment != nil) {
                        bestAttemptContent.body = NSLocalizedString("Send an attachment", comment: "")
                    }
                    NotiState.shared.selectedGroupId = data.group.id
                    //                let userDf = UserDefaults(suiteName: "group.ailaai.pushnotifications")
                    //                UserDefaults.standard.setValue("Hello", forKey: "Tmp1")
                    userDf.set(data.group.id, forKey: "notificationGroupId")
                    userDf.set(data.person.id, forKey: "notificationSenderId")
                    userDf.synchronize()
                } else if (notification.action == "Group") {
                    if (notification.data.event == "Join") {
                        let prefixStr = NSLocalizedString("You have been added to group", comment: "")
                        let someGroup = notification.data.group.name ?? NSLocalizedString("someGroup", comment: "")
                        let by = NSLocalizedString("by", comment: "")
                        let someone = notification.data.details?.invitor.name ?? NSLocalizedString("someone", comment: "")
                        bestAttemptContent.body = "\(prefixStr) \(someGroup) \(by) \(someone)"
                        let data = notification.data
                        userDf.set(data.group.id, forKey: "notificationGroupId")
                        userDf.set(data.details?.invitor.id, forKey: "notificationSenderId")
                        userDf.synchronize()
                    }
                }
                contentHandler(bestAttemptContent)
            }
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
